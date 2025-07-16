from os import environ
from json import dumps
from logging import Logger, getLogger

############
# Variables
############
log_level: str = environ.get("LOG_LEVEL", "DEBUG")

################
# Logging setup
#################
logger: Logger = getLogger(__name__)
logger.setLevel(log_level)

#####################
# Lambda entry point
#####################
def lambda_handler(event, context) -> dict[str, int | str | dict[str, int | str]]:
     signature_verified: bool = event.get("signature_verified", False)
     interaction_type: int = event.get("interaction_type", 1)
     status_code: int = event.get("statusCode", 401)

     logger.info(f"Event: {dumps(event, indent = 2)}")

     if (
          signature_verified and
          interaction_type == 1 and
          status_code in [200, 201]
     ):
          return {
               "statusCode": 200,
               "headers": {"Content-Type": "application/json"},
               "body": dumps({"type": 1})
          }

     else:
          return {"statusCode": 401, "body": "invalid request signature"}
