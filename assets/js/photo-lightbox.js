document.addEventListener('DOMContentLoaded', () => {
  const lightbox = document.getElementById('lightbox');

  if (!lightbox) {
    return;
  }

  const lightboxImage = lightbox.querySelector('img');
  const closeButton = lightbox.querySelector('.lightbox-close');
  let trigger = null;

  const openLightbox = (image) => {
    trigger = image;
    lightboxImage.src = image.src;
    lightboxImage.alt = image.alt;
    lightbox.classList.add('active');
    lightbox.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
    closeButton.focus();
  };

  const closeLightbox = () => {
    lightbox.classList.remove('active');
    lightbox.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
    trigger?.focus();
  };

  document.querySelectorAll('.photo-item img').forEach((image) => {
    image.addEventListener('click', () => openLightbox(image));
    image.addEventListener('keydown', (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        openLightbox(image);
      }
    });
  });

  closeButton.addEventListener('click', closeLightbox);
  lightbox.addEventListener('click', (event) => {
    if (event.target === lightbox) {
      closeLightbox();
    }
  });
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && lightbox.classList.contains('active')) {
      closeLightbox();
    }
  });
});