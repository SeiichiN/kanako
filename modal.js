$(function(){
	var $overlay = $('.modal-overlay');
	var $panel = $('.modal');

	function setPosition(){
		var panelHeight = $panel.height();
		var windowHeight = $(window).height();
		var adjustPosition = (windowHeight - panelHeight)/2;
		$panel.css("top", adjustPosition);
	}

	function hideModal(){
		$overlay.fadeOut();
		$panel.fadeOut();
	}

	$('.message-btn').click(function(e){
		e.preventDefault();
		$panel.fadeIn();
		$overlay.fadeIn();
		setPosition();
		$(this).parent().addClass('flag');
	});

	$(window).on('resize',function(){
		setPosition();
	});

	$overlay.click(function(){
		hideModal();
	});

	$('.modal-close').click(function(e){
		e.preventDefault();
		hideModal();
	});
});