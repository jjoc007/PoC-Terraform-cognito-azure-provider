
data "aws_iam_policy_document" "cognito_sns_publish_policy" {
  statement {
    actions   = ["sns:Publish"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role_policy_cognito" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "cognito_sns_role_policy" {
  name   = "terra-test-cognito-sns-role-policy"
  policy = data.aws_iam_policy_document.cognito_sns_publish_policy.json
}

resource "aws_iam_role" "iam_role_cognito_sms" {
  name               = "terra-test-cognito-sms-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_cognito.json
  path               = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_cognito_sns_role_policy" {
  role       = aws_iam_role.iam_role_cognito_sms.name
  policy_arn = aws_iam_policy.cognito_sns_role_policy.arn
}

resource "aws_cognito_user_pool" "pool" {
  name                       = "cognito-test-terra-user-pool"
  auto_verified_attributes   = ["email"]
  email_verification_subject = "Su código de verificación"
  email_verification_message = "Su código de verificación es {####}. "
  sms_authentication_message = "Su código de autenticación es {####}. "
  sms_verification_message   = "Su código de verificación es {####}. "
  username_attributes        = ["email"]

  depends_on = [aws_iam_role_policy_attachment.policy_attachment_cognito_sns_role_policy]
}

resource "aws_cognito_user_pool_client" "cognito_service_terra_test" {
  name                 = "cognito-service-terra-test-app"
  user_pool_id         = aws_cognito_user_pool.pool.id
  allowed_oauth_scopes = ["openid", "phone", "aws.cognito.signin.user.admin", "profile", "email"]
  allowed_oauth_flows  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers         = [aws_cognito_identity_provider.identity_provider.provider_name]
  callback_urls        = var.cognito_callback_urls
  logout_urls          = var.cognito_logout_urls
  explicit_auth_flows  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
  generate_secret      = false

  read_attributes  = local.COGNITO_READ_ATTRIBUTES
  write_attributes = local.COGNITO_WRITE_ATTRIBUTES
}

resource "aws_cognito_identity_provider" "identity_provider" {
  user_pool_id  = aws_cognito_user_pool.pool.id
  provider_name = "Provider-saml"
  provider_type = "SAML"

  provider_details = {
    MetadataURL  = "https://login.microsoftonline.com/fec9faa7-6465-47a2-a84e-f870ed6489bd/federationmetadata/2007-06/federationmetadata.xml?appid=af313f85-1994-43a3-a9c2-792993439991"
    "IDPSignout" =  "true"
  }
  attribute_mapping = {
    name        = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    email       = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
  }
}
