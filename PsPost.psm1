<#
   Creation 2015/9/8
   Createby Zoar.
   FileName PsPost.psm1

   Module Name PsPost
   このクライアントはメッセージの送信機能のみです。
   
#>

$ModulePath = "$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules\PsPost"
$CoreTweetPath = "$ModulePath\lib\CoreTweet.dll"
$SettingJson = "$ModulePath\setting.json"

$AzureConnectionKey = "wneOHhl6EyU9QDTKncSADkZtz"
$AzureConnectionID = "G0Csc5cwoGpqho8QYH4pR4suohRLQvBRUFaOh6vy9dwH5XNXT6"

[void][System.Reflection.Assembly]::LoadFrom($CoreTweetPath)

Function Get-PspostOAuth() {
   $Session = [CoreTweet.Oauth]::Authorize($AzureConnectionKey, $AzureConnectionID)
   Write-Host "Access in your browser to the This URL, and Please approve."
   Write-Host $Session.AuthorizeUri.AbsoluteUri
   $PIN = Read-Host "Input your PIN code."

   if ( $PIN -ne "" ) {
      $token = [CoreTweet.OAuth]::GetTokens($session, $PIN)
      $AccessToken = $token.AccessToken
      $AccessTokenSecret  = $token.AccessTokenSecret

      $setting = @{AccessToken = $AccessToken; AccessTokenSecret = $AccessTokenSecret}
      $setting | ConvertTo-Json | Out-File $SettingJson
      Write-Host "It was authenticated."
      Write-Host "Maybe."
   }
}

Function Send-Text() {
   param (
      [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [ValidateLength(1, 140)]
      [string]$Message
   )

   if ( Test-Path $SettingJson ) {
      $keys = Get-Content $SettingJson -Raw | ConvertFrom-Json
      $tokens = [CoreTweet.Tokens]::Create($AzureConnectionKey, $AzureConnectionID, $keys.AccessToken, $keys.AccessTokenSecret)

      try {
         $tweet = $tokens.Statuses.Update($Message)
      }catch{
         #Write-Output $error
      }
   } else {
      Write-Host "Key File is Empty. or Access denned."
      Write-Host "Please run 'Get-PspostOAuth' Command." -ForegroundColor Red
   }
}

Export-ModuleMember -Function *