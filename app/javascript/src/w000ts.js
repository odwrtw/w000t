import Tokenfield from 'bootstrap-tokenfield'
import Masonry from 'masonry-layout'
import imagesloaded from 'imagesloaded'

// Define a jQuery sub that will select the text of a div
$.fn.selectText = function() {
  let range;
  const doc = document;
  const element = this[0];
  if (doc.body.createTextRange) {
    range = document.body.createTextRange;
    range.moveToElementText(element);
    return range.select();
  } else if (window.getSelection) {
    const selection = window.getSelection();
    range = document.createRange();
    range.selectNodeContents(element);
    selection.removeAllRanges();
    return selection.addRange(range);
  }
};

$(document).on('turbolinks:load', function() {
  if ($(".w000ts").length) {
    $("a.type-youtube").click(event => $('#w000t-preview-modal').modal());
  }

  if ($(".w000ts.new").length) {
    $(".w000t-wat").click(function(event){
      $('.upload-image').toggle(300);
      return $('.form-url').toggle(300);
    });
  }

  if ($(".w000ts.owner_list").length) {
    $("#search-toggle button").click(function(event){
      $('#search-forms div.form').hide();
      return $('#'+this.id+'-form').show();
    });

    new Tokenfield(document.querySelector(".tags-search"))
    new Tokenfield(document.querySelector(".w000t-tags-form"))
    $("div.container").delegate(".w000t-tags", "click", function() {
      $(".tags-input-displayed").hide();
      $(".tags-td-hidden").show();
      const $el = $(this).closest("td").siblings(".w000t-form");
      $el.show();
      $el.addClass("tags-input-displayed");
      $el.find('input').focus();
      return $(this).hide().addClass('tags-td-hidden');
    });
  }

  if ($('.w000ts.owner_wall, .w000ts.user_wall, .w000ts.public_wall').length ) {
    // When we click on the current status, we show a ul with the others statuses
    $("div.container").delegate("td.w000t-status", "click", function() {
      return $(this).parents("figure").find(".w000t-form-status").toggle();
    });

    // When we click on the share button, we show a div with the w000ted url and
    // select the text
    $("div.container").delegate("a.to_share", "click", function() {
      const $el = $(this).closest("div").siblings(".shared");
      $el.show();
      return $el.selectText();
    });

    // When we leave the figure, we need to hide the w000ted url that was shown by
    // clicking on the share button and the status form
    $("div.container").delegate("figure", "mouseleave", function() {
      $(this).children(".shared").hide();
      return $(this).children(".w000t-form-status").hide();
    });

    // Masonry options
    const masonry_options = {
      itemSelector: ".item",
      transitionDuration: 0,
      stamp: '.stamp',
    };

    var msnry = new Masonry( 'div#w000t-wall-container', masonry_options);

    let count = 0;
    var onProgress = function( instance, image ) {
      count++;
      // When the image is loaded, remove the hidden class
      if (image.isLoaded) {
        image.img.classList.remove("hidden");
        image.img.classList.add("stamp");
      }
      // Every 4 images loaded, trigger the redraw of Masonry
      if ((count % 4) === 0) {
        msnry && msnry.layout();
        return msnry;
      }
    }

    var $container = $("div#w000t-wall-container");

    imagesLoaded.makeJQueryPlugin( $ );
    $container.imagesLoaded().progress(onProgress);

    var onGoing = false;
    $(window).on('scroll', function() {
      var more_posts_url = $("ul.pagination li a[rel='next']").attr('href');
      if (more_posts_url && ($(window).scrollTop() > $(document).height() - $(window).height() - 600)) {
        if (onGoing) {
          return;
        }
        onGoing = true;
        $.ajax({url: more_posts_url, success: function(result){
          // Replace new pagination
          var $newPagination = $(result).find("ul.pagination li");
          $("ul.pagination").html($newPagination);
          // Append new w000ts
          var $items = $(result).find('#w000t-wall-container .item');
          $container.append($items);
          msnry.appended( $items );
          $container.imagesLoaded().progress(onProgress);

          onGoing = false;
        }});
      }
    });
  }
});
