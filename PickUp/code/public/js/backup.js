var onHomepage = true;


var home = document.getElementById("home");
  home.addEventListener("click", function(event){
  //event.preventDefault();
   onHomepage = true;
    document.getElementById("main_content").style.opacity="1";
      document.getElementById("about_content").style.display="none";

});

var about = document.getElementById("about");
  about.addEventListener("click", function(event){
  //event.preventDefault();
   onHomepage = false;
   console.log("about");
      document.getElementById("main_content").style.opacity="0";

  document.getElementById("about_content").style.display="initial";

});

  $.backstretch([
    "img/anything.jpg",
    "img/bartend.jpg",
     "img/dj.jpg",
    "img/sail.jpg",
     "img/surf.jpg",
     "img/sushi.jpg"
  ], {
        fade:500,
      duration: 2500
  });


  var spans = [].slice.call(document.querySelectorAll('.rw-words span')),
    words = document.querySelector('.rw-words'),
    maxwidth = Math.max.apply(null, spans.map(function (item) {
       return item.offsetWidth;
    }));
words.style.width = maxwidth + 'px'


// //for testing purposes
// $.backstretch([
//   "http://placekitten.com/g/2000/1000",
//   "http://placekitten.com/g/1000/1000",
//     "http://placekitten.com/g/2000/1000",
//   "http://placekitten.com/g/1000/1000",
//     "http://placekitten.com/g/2000/1000",
//   "http://placekitten.com/g/1000/1000"
// ], {
//     fade:500,
//     duration: 2500
// });

// var spans = [].slice.call(document.querySelectorAll('.rw-words span')),
//     words = document.querySelector('.rw-words'),
//     maxwidth = Math.max.apply(null, spans.map(function (item) {
//        return item.offsetWidth;
//     }));
// words.style.width = maxwidth + 'px'