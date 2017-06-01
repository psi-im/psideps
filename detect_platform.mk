UNAME := $(shell uname)

ifeq ($(PLATFORM),)
ifeq ($(UNAME), Darwin)
PLATFORM = mac
else ifeq ($(findstring MINGW,$(UNAME)),MINGW)
PLATFORM = win
endif
PLATFORM =
endif
export PLATFORM

ifeq($(PLATFORM),)
DEFAULT_TARGET=default-unknown
else
DEFAULT_TARGET=default-$(PLATFORM)
endif
