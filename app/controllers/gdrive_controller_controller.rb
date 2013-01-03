class GdriveControllerController < ApplicationController
  CLIENT_ID = '346004285230.apps.googleusercontent.com'
  CLIENT_SECRET = 'jYsRkP8KRNEhRGN2R-dUj0XS'
  REDIRECT_URI = 'リダイレクトURI文字列'
  OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'
  def index
    session[:token] = params[:token]

    client = Google::APIClient.new
    drive = client.discovered_api('drive', 'v2')
    client.authorization.client_id = CLIENT_ID
    client.authorization.client_secret = CLIENT_SECRET
    client.authorization.scope = OAUTH_SCOPE
    client.authorization.redirect_uri = REDIRECT_URI

    uri = client.authorization.authorization_uri
    redirect_to uri.to_s
  end

  def callback
    client = Google::APIClient.new
    client.authorization.client_id = CLIENT_ID
    client.authorization.client_secret = CLIENT_SECRET
    client.authorization.redirect_uri = REDIRECT_URI
    client.authorization.code = params[:code]
    token_info = client.authorization.fetch_access_token!
    token_info['issue_timestamp'] = Time.now
  end

  token_info = Session.get_gdrive_session(token)
  raise 'Not authorized' unless token_info
  if Time.now > (token_info['issue_timestamp'] + token_info['expires_in'])
    client = Google::APIClient.new
    client.authorization.client_id = CLIENT_ID
    client.authorization.client_secret = CLIENT_SECRET
    client.authorization.update_token!(token_info)
    client.authorization.grant_type = 'refresh_token'
    token_info = client.authorization.fetch_access_token!
    token_info['issue_timestamp'] = Time.now
    Session.set_gdrive_session(token, token_info)
  end
  token_info

  token_info = ... # さっき取得したやつ
      client = Google::APIClient.new
  client.authorization.update_token!(token_info)
  drive = client.discovered_api('drive', 'v2')

  folder =drive.files.insert.request_schema.new({
                                                    'title' => 'フォルダのタイトル文字列',
                                                    'description' => 'フォルダの説明文',
                                                    'mimeType' => 'application/vnd.google-apps.folder'
                                                })
  result = client.execute(
      :api_method => drive.files.insert,
      :body_object => folder
  )
  parent_id = result.data.to_hash['id']
end
