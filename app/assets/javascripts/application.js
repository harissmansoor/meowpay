document.addEventListener('DOMContentLoaded', function () {
  for (const flash of document.querySelectorAll('.flash')) {
    const dismiss = flash.querySelector('.flash-dismiss')

    function hide() {
      if (flash.classList.contains('flash-hiding')) return
      flash.classList.add('flash-hiding')
      flash.addEventListener('animationend', function () {
        flash.remove()
      }, { once: true })
    }

    dismiss?.addEventListener('click', hide)
    setTimeout(hide, 4000)
  }
})
