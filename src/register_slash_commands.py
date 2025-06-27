from sys import exit
from os import environ
from typing import Any
from requests import Response, post
from logging import Logger, basicConfig, getLogger

############
# Variables
############
log_level: str = environ.get("LOG_LEVEL", "DEBUG")
DISCORD_TOKEN: str | None = environ.get("DISCORD_TOKEN")
APPLICATION_ID: str | None = environ.get("APPLICATION_ID")
DISCORD_API_URL: str = f"https://discord.com/api/v10/applications/{APPLICATION_ID}/commands"

################
# Logging setup
################
basicConfig(level = log_level)
logger: Logger = getLogger(__name__)

##########################
# Register Slash Commands
##########################
def register_slash_commands(slash_command: dict[str, str | int]) -> Response:
     headers: dict[str, str] = {
          "Authorization": f"Bot {DISCORD_TOKEN}",
          "Content-Type": "application/json"
     }
     response: Response = post(DISCORD_API_URL, headers = headers, json = slash_command)

     return response

#######
# Main
#######
def main() -> None:
     if not DISCORD_TOKEN or not APPLICATION_ID:
          logger.error("DISCORD_TOKEN or APPLICATION_ID is not set in the environment variables.")
          exit(1)

     slash_commands: list[dict[str, str | Any]] = [
          {"name": "start", "type": 1, "description": "Show the bot capabilities."},
          {"name": "launch-instance", "type": 1, "description": "Launch a new Amazon EC2 instance."},
     ]

     for command in slash_commands:
          response: Response = register_slash_commands(command)
          if response.status_code in [200, 201]:
               logger.info(f"Command '{command['name']}' registered successfully.")
          else:
               logger.error(
                f"Failed to register command '{command['name']}'. "
                f"Status code: {response.status_code}, Response: {response.text}"
            )

if __name__ == "__main__":
    main()
