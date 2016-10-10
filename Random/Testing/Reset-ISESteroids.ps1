function Reset-ISESteroids {
  Remove-Item -Path 'hkcu:\SOFTWARE\Classes\CLSID\{b0ddb34c-afdc-f3b1-fa59-2749aea28c234}'
  
  # Remove if nothing else helps...
  #Remove-Item -Path 'hkcu:\SOFTWARE\Classes\CLSID\{f655a448-58b7-134f-63cf-59cbff42b85b0}'
}