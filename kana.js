
window.onload = function(){
	/* ログエリアの最下行を常に表示させる */
	var logarea = document.getElementById('log_area');
	if(!logarea) return;
	logarea.scrollTop = logarea.scrollHeight;

	/* ノーマルなかなこ */
	/* document.anime.src = "bmps/talk.gif"; */

	/* ふだんのかなこ */
	var timer;
	timer = window.setInterval(
		function(){
			var choice = Math.floor(Math.random() * 5);
			switch(choice){
				case 0:
				case 1:
					/* var figure = document.getElementsByTagName('figure') */
					if (document.getElementById('normal')){
						document.anime.src = "bmps/normal.gif";
					} else if(document.getElementById('angry')){
						document.anime.src = "bmps/angry.gif";
					} else if(document.getElementById('more_angry')){
						document.anime.src = "bmps/more_angry.gif";
					} else if(document.getElementById('happy')){
						document.anime.src = "bmps/happy.gif";
					} else if(document.getElementById('more_happy')){
						document.anime.src = "bmps/more_happy.gif";
					} else {
						document.anime.src = "bmps/normal.gif";
					}
					break;
				case 2:
					/* var figure = document.getElementsByTagName('figure') */
					if (document.getElementById('normal')){
						document.anime.src = "bmps/lookaround.gif";
					} else if(document.getElementById('angry')){
						document.anime.src = "bmps/knock.gif";
					} else if(document.getElementById('more_angry')){
						document.anime.src = "bmps/armfold.gif";
					} else if(document.getElementById('happy')){
						document.anime.src = "bmps/giggle.gif";
					} else if(document.getElementById('more_happy')){
						document.anime.src = "bmps/blush.gif";
					} else {
						document.anime.src = "bmps/lookaround.gif";
					}
					break;
				case 3:
				case 4:
					/* var figure = document.getElementsByTagName('figure') */
					if (document.getElementById('normal')){
						document.anime.src = "bmps/blink.gif";
					} else if(document.getElementById('angry')){
						document.anime.src = "bmps/sigh.gif";
					} else if(document.getElementById('more_angry')){
						document.anime.src = "bmps/snap.gif";
					} else if(document.getElementById('happy')){
						document.anime.src = "bmps/happy_blink.gif";
					} else if(document.getElementById('more_happy')){
						document.anime.src = "bmps/more_happy_blink.gif";
					} else {
						document.anime.src = "bmps/blink.gif";
					}
					break;
				default:
					document.anime.src = "bmps/normal.gif";
			}
		},3000
	);
	/* 実行されるけど、クエリ処理によって再描画されるので、結局表示されない。 */
/*	document.getElementById('btn-talk').onclick = function(){
		document.anime.src = "bmps/talk.gif";
		console.log('btn-talk Clicked!');
	};
*/
};

