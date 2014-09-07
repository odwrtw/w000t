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
  masonry_options =
    itemSelector: '.item'

  # Load masonry on page ready
  $container = $("div#w000t-wall-container").masonry(masonry_options)

  # layout Masonry again after all images have loaded
  $container.imagesLoaded ->
    console.log 'Image loaded'
    $container.masonry(masonry_options)
    return

