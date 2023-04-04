# Load environment variables from .env file
include .env

# Targets
init:
	AWS_ACCESS_KEY_ID      = $(AWS_ACCESS_KEY_ID)=  $(AWS_SECRET_ACCESS_KEY )

plan:
	AWS_ACCESS_KEY_ID      = $(AWS_ACCESS_KEY_ID)=  $(AWS_SECRET_ACCESS_KEY )
apply:
	AWS_ACCESS_KEY_ID      = $(AWS_ACCESS_KEY_ID)=  $(AWS_SECRET_ACCESS_KEY )

destroy:
	AWS_ACCESS_KEY_ID      = $(AWS_ACCESS_KEY_ID)=  $(AWS_SECRET_ACCESS_KEY )