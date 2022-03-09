FUNCTION zits_get_user_profile_buffer.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(ES_USER_PROFILE) TYPE  ZSITS_USER_PROFILE
*"----------------------------------------------------------------------

  CLEAR es_user_profile.

*  GET PARAMETER ID 'ZUP' FIELD es_user_profile.
  GET PARAMETER ID 'WRK' FIELD es_user_profile-zzwerks.
  GET PARAMETER ID 'LGN' FIELD es_user_profile-zzlgnum.
  GET PARAMETER ID 'LAG' FIELD es_user_profile-zzcurr_loc.
ENDFUNCTION.
