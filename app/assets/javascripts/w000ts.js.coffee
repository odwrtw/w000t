# Define a jQuery sub that will select the text of a div
$ = jQuery
$.fn.selectText = ->
  doc = document
  element = this[0]
  if (doc.body.createTextRange)
    range = document.body.createTextRange()
    range.moveToElementText(element)
    range.select()
  else if window.getSelection
    selection = window.getSelection()
    range = document.createRange()
    range.selectNodeContents(element)
    selection.removeAllRanges()
    selection.addRange(range)

$(document).on 'turbolinks:load', ->
  if ($(".w000ts").length)
    $("a.type-youtube").click (event)->
      $('#w000t-preview-modal').modal()

  if ($(".w000ts.new").length)
    $(".w000t-wat").click (event)->
      $('.upload-image').toggle(300)
      $('.form-url').toggle(300)

  if ($(".w000ts.owner_list").length)
    $("#search-toggle button").click (event)->
      $('#search-forms div.form').hide()
      $('#'+this.id+'-form').show()

    $('.tags-search').tokenfield()
    $('.w000t-tags-form').tokenfield()
    $("div.container").delegate ".w000t-tags", "click", ->
      $(".tags-input-displayed").hide()
      $(".tags-td-hidden").show()
      $el = $(this).closest("td").siblings(".w000t-form")
      $el.show()
      $el.addClass("tags-input-displayed")
      $el.find('input').focus()
      $(this).hide().addClass('tags-td-hidden')

  if ($('.w000ts.owner_wall, .w000ts.user_wall, .w000ts.public_wall').length )
    # When we click on the current status, we show a ul with the others statuses
    $("div.container").delegate "td.w000t-status", "click", ->
      $(this).parents("figure").find(".w000t-form-status").toggle()

    # When we click on the share button, we show a div with the w000ted url and
    # select the text
    $("div.container").delegate "a.to_share", "click", ->
      $el = $(this).closest("div").siblings(".shared")
      $el.show()
      $el.selectText()

    # When we leave the figure, we need to hide the w000ted url that was shown by
    # clicking on the share button and the status form
    $("div.container").delegate "figure", "mouseleave", ->
      $(this).children(".shared").hide()
      $(this).children(".w000t-form-status").hide()

    # Masonry options
    masonry_options =
      itemSelector: ".item"

    # Image container
    $container = $("div#w000t-wall-container")
    $container.masonry(masonry_options)

    imgLoad = imagesLoaded($container)

    # Update layout on each image load
    count = 0
    imgLoad.on 'progress', ->
      count++
      if ((count % 4) == 0)
        $container.masonry masonry_options

    # Update layout when all the images are loaded
    imgLoad.on 'always', ->
      $container.masonry masonry_options

    $container.infinitescroll(
      # selector for the paged navigation (it will be hidden)
      navSelector  : "ul.pagination"
      # selector for the NEXT link (to page 2)
      nextSelector : "ul.pagination li a[rel='next']"

      # selector for all items you'll retrieve
      itemSelector : "#w000t-wall-container .item"
      extraScrollPx:10
      loading:
        finished: undefined
        finishedMsg: "<em>Congratulations, you've reached the end of the internet.</em>", img: null
        msg: null
        msgText: "<em>Loading the next set of posts...</em>"
        selector: null
        speed: 'fast'
        start: undefined
      , (newElements) ->
        $newElems = $( newElements ).css({ opacity: 0 })
        $newElems.imagesLoaded ->
          $newElems.animate({ opacity: 1 })
          $container.masonry "appended", $newElems
          return
    )

$(document).on 'page:fetch', ->
  $container = $("div#w000t-wall-container")
  $container.infinitescroll('destroy')
