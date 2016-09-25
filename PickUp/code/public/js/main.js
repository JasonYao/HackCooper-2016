var onHomepage = true;


var letMeIn = document.getElementById("letmeinbutton");
  letMeIn.addEventListener("click", function(event){
  //event.preventDefault();
  document.getElementById("ready").innerHTML= "We will let you know when it's ready. <br> In the meantime, share TakeUp with your friends.";
  document.getElementById("email_holder").style.opacity="0";
});

var logoClick = document.getElementById("logo");
  logoClick.addEventListener("click", function(event){
  //event.preventDefault();
  location.reload();
});

var disableScroll = false;

function disableScrolling() {
    disableScroll = true;
}


function enableScrolling() {
    disableScroll = false;
}

function refreshWindow(){


  var mql = window.matchMedia("screen and (max-width: 1011px)")
  if (mql.matches){ // if media query matches
    location.reload();
  }
  else{
    // do something else
  }
}

document.ontouchmove = function(e){
   if(disableScroll){
     e.preventDefault();
   } 
}

$("#home").hover(function(){
    $(this).css("border-bottom", "solid 1px");
    }, function(){
      if(onHomepage == true){
        $(this).css("border-bottom", "solid 1px");
      }
      else{
         $(this).css("border-bottom", "0");
      }
    
});

$("#about").hover(function(){
    $(this).css("border-bottom", "solid 1px");
    }, function(){
      if(onHomepage == false){
        $(this).css("border-bottom", "solid 1px");
      }
      else{
         $(this).css("border-bottom", "0");
      }
    
});




var home = document.getElementById("home");
  home.addEventListener("click", function(event){
  //event.preventDefault();
   onHomepage = true;
    document.getElementById("main_content").style.opacity="1";
    document.getElementById("about_content").style.opacity="0";
    document.getElementById("about").style.borderBottom="0";
    document.getElementById("home").style.borderBottom="solid 1px";
    document.getElementById("body").style.overflow="inherit";
    enableScrolling();

});

var about = document.getElementById("about");
  about.addEventListener("click", function(event){
  //event.preventDefault();
   onHomepage = false;
   console.log("about");
    document.getElementById("main_content").style.opacity="0";
    document.getElementById("about_content").style.opacity="1";
    document.getElementById("about").style.borderBottom="solid 1px";
    document.getElementById("home").style.borderBottom="0";
    document.getElementById("body").style.overflow="hidden";

    disableScrolling();


});



  $('#backstretchTest').backstretch([
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
words.style.width = maxwidth + 'px';


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