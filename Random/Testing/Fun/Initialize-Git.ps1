function Initialize-Git {
  <#
      .SYNOPSIS
      Configure your Git/GitHub profile

      .DESCRIPTION
      Configure your Git/GitHub profile. Should be run once to set some initial settings when on a new system or to reset the actual config.
      $GitName              = 'Velocet'
      $GitMail              = 'velocet@users.noreply.github.com'
      $GitEditor            = "`'${env:ProgramFiles(x86)}\Notepad++\notepad++.exe`' -multiInst -nosession"
      $GitRepo              = "`'$([Environment]::GetFolderPath(“MyDocuments”))/GitHub`'"
      $GitPush              = 'Simple'
      $GitCredentialHelper  = 'wincred'

      .EXAMPLE
      Initialize-Git
      Configure your Git/GitHub profile.

      .EXAMPLE
      Edit Initialize-Git
      $GitName              = 'Velocet'
      $GitMail              = 'velocet@users.noreply.github.com'
      $GitEditor            = "`'${env:ProgramFiles(x86)}\Notepad++\notepad++.exe`' -multiInst -nosession"
      $GitRepo              = "`'$([Environment]::GetFolderPath(“MyDocuments”))/GitHub`'"
      $GitPush              = 'Simple'
      $GitCredentialHelper  = 'wincred'

      .NOTES
      Before the first run you have to configure the script.

      .LINK
      https://git-scm.com
      Git SCM
  #>
  
  # Install the 'Git Credential Manager for Windows' to save/use your Git credentials with Windows's build-in credential manager
  if (!((choco list --local-only 'Git-Credential-Manager-for-Windows') -match 'Git-Credential-Manager-for-Windows')) { choco install Git-Credential-Manager-for-Windows }
  
  # GitHub Settings
  $env:PLINK_PROTOCOL = "ssh"
  $env:TERM = "msys"
  $env:TMP = $env:TEMP = [system.io.path]::gettemppath()
  $env:EDITOR = "GitPad"

  git config --global credential.helper $GitCredentialHelper
  git config --global user.name $GitName
  git config --global user.email $GitMail
  git config --global push.default $GitPush
  git config --global core.editor $GitEditor
  git config --global recentrepo $GitRepo
  
  <#
      GIT_AUTHOR_NAME is the human-readable name in the “author” field.
      GIT_AUTHOR_EMAIL is the email for the “author” field.
      GIT_AUTHOR_DATE is the timestamp used for the “author” field.
      GIT_COMMITTER_NAME sets the human name for the “committer” field.
      GIT_COMMITTER_EMAIL is the email address for the “committer” field.
      GIT_COMMITTER_DATE i
  #>
}
