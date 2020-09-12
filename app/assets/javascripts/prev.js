function previewFile() {
  const target = this.event.target;
  const image_file = target.files[0];
  const reader  = new FileReader();
	const api_key = 'AIzaSyC4Zapq9Lizc0BSLzrqbW6AWhijb0y00Dw';
  const url = `https://vision.googleapis.com/v1/images:annotate`;
	const sendAPI = (base64string) => {
    let body = {
      requests: [
        {image: {content: base64string}, features: [{type: 'FACE_DETECTION'}, {type: 'SAFE_SEARCH_DETECTION'}, {type: 'WEB_DETECTION'}]}
      ]
    };
    let xhr = new XMLHttpRequest();
    xhr.open('POST', `${url}?key=${api_key}`, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    const p = new Promise((resolve, reject) => {
      xhr.onreadystatechange = () => {
        if (xhr.readyState != XMLHttpRequest.DONE) return;
        if (xhr.status >= 400) return reject({message: `Failed with ${xhr.status}:${xhr.statusText}`});
        resolve(JSON.parse(xhr.responseText));
      };
    })
    xhr.send(JSON.stringify(body));
    return p;
  }
	const readFile = (file) => {
    let reader = new FileReader();
    const p = new Promise((resolve, reject) => {
      reader.onload = (ev) => {
        document.querySelector('img').setAttribute('src', ev.target.result);
        resolve(ev.target.result.replace(/^data:image\/(png|jpeg);base64,/, ''));
      };
    })
    reader.readAsDataURL(file);
    return p;
  };


  reader.onloadend = function () {
      const preview = document.querySelector("#preview")
      console.log(preview);
      if(preview) {
          preview.src = reader.result;
      }
  }
  if (image_file) {
      reader.readAsDataURL(image_file);
  }

    Promise.resolve(image_file)
      .then(readFile)
      .then(sendAPI)
      .then(res => {
        
        var response = res;
        $.ajax({
 		    	 url: '/posts',
    		 	 type: "POST",
     			 data: response,
     			 dataType: "json",
           }).done(function(data) {
            document.querySelector('#sindan_result').innerHTML = data.body;
            console.log(data)
            })
            .fail(function() {
            alert("error!");  // 通信に失敗した場合はアラートを表示
            })

        console.log('SUCCESS!', res);
      //  document.querySelector('#sindan_result').innerHTML = JSON.stringify(res);
      })
      .catch(err => {

				console.log(image_file);
        console.log('FAILED:(', err);
        document.querySelector('#sindan_result').innerHTML = JSON.stringify(err, null, 2);
      });
}