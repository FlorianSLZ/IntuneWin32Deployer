$PublicDesktop = Get-ChildItem "C:\Users\Public\Desktop\*"

If($PublicDesktop){exit 1}else{exit 0} # exit 1 = detectet, remediation needed