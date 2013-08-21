<?php
if(isset($_FILES['uploadFile']))
{
	move_uploaded_file($_FILES['uploadFile']['tmp_name'], './uploaded.jpg');
	header('Content-Type: application/json');
	echo json_encode(array('er' => "1\n2"));
	exit;
}
?><html>
<head>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js"></script>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
<script type="text/javascript">
var webcam = {
	link: null,
	swf: 'AKWebcam.swf' + '?' + (new Date().getTime()) // remove timestamp for production
	, placeholder: 'camera'
	, flasVars: {
		eventListener: 'webcam.listener',
		movieWidth: 320,
		movieHeight: 240,

		cameraWidth: 1920,
		cameraHeight: 1080
	}
	, movieParams: {
		wmode: "transparent",
		allowscriptaccess: "always"
	}
	, attrs: {
		id: 'AKWebcamPicture'
	}
	, swfobjectCallback: function(event){
		webcam.link = event.ref;
	}
	, shootParams: {
		target: 'index.php',
		fileInputName: 'uploadFile',
		dataType: 'json',
		fields: {
			toto: 'cmoi',
			returnType: 'json'
		}
	}
	, listener: function(event){
		// prevent Flash freezing
		if(!event['dispatch'])
		{
			event['dispatch'] = true;
			setTimeout(function(){webcam.listener(event)}, 10);
		}
		else
		{
			console.log('dispatched event', event.name);
		}
	}
};
$(function(){
	$(document).on('click', '.shoot', function(){
		webcam.link.swfCall('capture', webcam.shootParams);
	});
	swfobject.embedSWF(webcam.swf, webcam.placeholder, "100%", "100%", "9.0.0", false, webcam.flasVars, webcam.movieParams, webcam.attrs, webcam.swfobjectCallback);
});
</script>
<style type="text/css">
#cam_container
{
	border: 5px solid gray;
	width: 320px;
	height: 240px;
	margin: 20px auto;
	position: relative;
}
.shoot
{
	position: absolute;
	bottom: 5px;
	background:	rgba(0,0,0,0.5);
	width: 150px;
	left: 50%;
	margin-left: -75px;
	border-radius: 5px;
	color: white;
	text-align: center;
	text-decoration: none;
	font-size: 15px;
	display: block;
	height: 25px;
	line-height: 25px;
}
.shoot:hover
{
	background:	rgba(0,0,0,0.8);
	color: lime;		
}
</style>
</head>
<body>
<div id="cam_container">
	<div id="camera"></div>
	<a href="#null" class="shoot">Shoot</a>
</div>
</body>
</html>