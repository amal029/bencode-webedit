window.onload = function() {
    var fileInput = document.getElementById('myInput');

    fileInput.addEventListener('change', function(e) {
	var file = fileInput.files[0];
	var textType = /text.*/;
	console.log(file);

	if (file.type.match(textType)) {
	    var reader = new FileReader();

	    reader.onload = function(e) {
		console.log(reader.result);
		$.ajax({
		    type:"POST",
		    url:"/ajax/hdata",
		    data: {'fcontent':reader.result},
		    success:function(response){
			$("#sformat").html(response);
		    }
		});
	    }

	    reader.readAsText(file);	
	} else {}
    });
}
