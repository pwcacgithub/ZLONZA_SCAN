*&---------------------------------------------------------------------*
*& Module Pool       SAPDZH09
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
*This program has been created for scanner requirement.
*This is used when a HU needs to be deleted. We scan the HU
*to be deleted. If there are no child HUs or if they are currently not packed,
*they can be deleted

INCLUDE dzh09top                                .    " global Data
INCLUDE dzh09o01                                .  " PBO-Modules
INCLUDE dzh09i01                                .  " PAI-Modules
INCLUDE dzh09f01                                .  " FORM-Routines
