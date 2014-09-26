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

$(".w000ts.my_image_index").ready ->
  # masonry options
  masonry_options =
    itemSelector: '.item'

  # Image container
  $container = $("div#w000t-wall-container")
  $container.masonry(masonry_options)

  imgLoad = imagesLoaded($container)

  # Update layout on each image load
  count = 0
  imgLoad.on 'progress', ->
    count++
    if ((count % 8) == 0)
      $container.masonry masonry_options

  # Update layout when all the images are loaded
  imgLoad.on 'always', ->
    $container.masonry masonry_options

  imagesLoad.on( 'layoutComplete', ( msnryInstance, laidOutItems ) ->
    console.log('Masonry layout completed on ' + laidOutItems.length + ' items')
  )

  $container.infinitescroll(
    # selector for the paged navigation (it will be hidden)
    navSelector  : "nav.pagination"
    # selector for the NEXT link (to page 2)
    nextSelector : "nav.pagination span.next a[rel='next']"
    # selector for all items you'll retrieve
    itemSelector : "#w000t-wall-container .item"
    extraScrollPx:200
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

$(document).on('page:fetch', ->
  $container = $("div#w000t-wall-container")
  $container.infinitescroll('destroy')
)
