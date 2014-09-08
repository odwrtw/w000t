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
  imgLoad = imagesLoaded($container)

  # Update layout on each image load
  imgLoad.on 'progress', -> $container.masonry masonry_options

  # Update layout when all the images are loaded
  imgLoad.on 'always', -> $container.masonry masonry_options
  return

