import nacl.signing
import nacl.exceptions
from os import environ
from boto3 import Session
from logging import Logger, getLogger
from botocore.exceptions import ClientError

############
# Variables
############
log_level: str = environ.get("LOG_LEVEL", "DEBUG")
parameter_store_name = environ.get("DISCORD_PUBLIC_KEY_NAME")

################
# Logging setup
#################
logger: Logger = getLogger(__name__)
logger.setLevel(log_level)

#########################
# Get Discord Public Key
#########################
def get_discord_public_key() -> str:
     session = Session()
     parameter_store = session.client("ssm")

     try:
          response = parameter_store.get_parameter(
               Name = parameter_store_name,
               WithDecryption = True
          )

          logger.info(f"Parameter store, {parameter_store_name}, found")
          return response["Parameter"]["Value"]
     except ClientError as e:
          if e.response["Error"]["Code"] == "ParameterNotFound":
               logger.error(f"Parameter not found: {parameter_store_name}")
          elif e.response["Error"]["Code"] == "ParameterVersionNotFound":
               logger.error(f"Parameter version not found: {parameter_store_name}")
          elif e.response["Error"]["Code"] == "InvalidKeyId":
               logger.error("Invalid Key ID for the parameter")
          elif e.response["Error"]["Code"] == "InternalServerError":
               logger.error("Internal server error while retrieving parameter")
          else:
               logger.error(f"Unexpected error retrieving parameter store from SSM: {e}")

          return ""

#####################
# Lambda entry point
#####################
def lambda_handler(event, context):
     headers = {k.lower(): v for k, v in event.get("headers", {}).items()}
     signature = headers.get("x-signature-ed25519")
     timestamp = headers.get("x-signature-timestamp")
     body = event.get("body", {})

     interaction_type = body.get("type", 1)

     if not signature or not timestamp:
          logger.error("The signature or timestamp from the request are empty")
          return {
               "signature": False,
               "interaction_type": interaction_type,
               "statusCode": 401
          }

     try:
          discord_public_key: str = get_discord_public_key()
          verify_key = nacl.signing.VerifyKey(bytes.fromhex(discord_public_key))
          verify_key.verify(f"{timestamp}{body}".encode(), bytes.fromhex(signature))
          return {
               "signature": True,
               "interaction_type": interaction_type,
               "statusCode": 200
          }
     except nacl.exceptions.BadSignatureError:
          logger.warning("Invalid signature")
          return {
               "signature": False,
               "interaction_type": interaction_type,
               "statusCode": 401
          }
