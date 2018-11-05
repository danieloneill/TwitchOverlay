<?php
	$a = $_GET['a'];
	$client_id = '<app client id>';
	$client_secret = '<app client secret>';

	function authenticate()
	{
		global $client_id, $client_secret;

		$code = $_GET['code'];
		$scope = $_GET['scope'];

		$url = 'https://id.twitch.tv/oauth2/token';
		$fields = array(
			'client_id' => $client_id,
			'client_secret' => $client_secret,
			'code' => $code,
			'grant_type' => 'authorization_code',
			'redirect_uri' => 'http://dawnnest.com/twitchoverlay.php'
		);
		$ch = curl_init($url);

		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

		$response = curl_exec($ch);
		curl_close($ch);

		print $response;
	}

	function refresh()
	{
		global $client_id, $client_secret;

		$token = $_GET['refresh'];

		$url = 'https://id.twitch.tv/oauth2/token';
		$fields = array(
			'client_id' => $client_id,
			'client_secret' => $client_secret,
			'refresh_token' => $token,
			'grant_type' => 'refresh_token'
		);

		$ch = curl_init($url);

		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

		$response = curl_exec($ch);
		curl_close($ch);

		print $response;
	}

	if( $a == 'refresh' )
		refresh();
	else
		authenticate();
?>
