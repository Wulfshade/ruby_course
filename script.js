// Function to toggle solution visibility
function toggleSolution(id, event) {
    console.log('[toggleSolution] Called for ID:', id); // For debugging
    if (event && typeof event.preventDefault === 'function') {
        console.log('[toggleSolution] Event object detected, calling preventDefault and stopPropagation.'); // For debugging
        event.preventDefault();
        event.stopPropagation(); // Explicitly stop propagation
    } else {
        console.warn('[toggleSolution] Event object missing or not a valid event.'); // For debugging
    }

    const solutionElement = document.getElementById(id);
    if (!solutionElement) {
        console.error('[toggleSolution] Solution element not found for ID:', id); // For debugging
        return false; 
    }

    const button = solutionElement.previousElementSibling;
    if (!button) {
        console.warn('[toggleSolution] Button (previousElementSibling) not found for solution ID:', id); // For debugging
    }

    // Check current display state. Also account for initially empty style.display.
    if (solutionElement.style.display === 'none' || solutionElement.style.display === '') {
        solutionElement.style.display = 'block';
        if (button) { // Only update textContent if button was found
            button.textContent = 'Hide Solution';
        }
    } else {
        solutionElement.style.display = 'none';
        if (button) { // Only update textContent if button was found
            button.textContent = 'Show Solution';
        }
    }

    console.log('[toggleSolution] Finished for ID:', id, '. Current display:', solutionElement.style.display); // For debugging
    return false; // This is important for inline event handlers to prevent default action
}

document.addEventListener('DOMContentLoaded', function() {
    // Add event listeners to prevent default action on all solution buttons
    const solutionButtons = document.querySelectorAll('.solution-btn');
    solutionButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            return false;
        });
    });
    
    // Handle slide navigation if we're on a chapter page with topic slides
    const slides = document.querySelectorAll('.topic-slide');
    const topicButtons = document.querySelectorAll('.topic-btn');
    
    // Handle the new slide navigation in chapters 0-12
    const newSlides = document.querySelectorAll('.slide');
    const prevSlideButtons = document.querySelectorAll('.prev-slide');
    const nextSlideButtons = document.querySelectorAll('.next-slide');
    
    if (slides.length > 0) {
        // Show the first slide by default
        slides[0].classList.add('active');
        
        // Activate the first topic button
        if (topicButtons.length > 0) {
            topicButtons[0].classList.add('active');
        }
        
        // Add click event listeners to topic buttons
        topicButtons.forEach(button => {
            button.addEventListener('click', function() {
                const targetSlide = this.getAttribute('data-target');
                
                // Hide all slides and deactivate all buttons
                slides.forEach(slide => slide.classList.remove('active'));
                topicButtons.forEach(btn => btn.classList.remove('active'));
                
                // Show target slide and activate clicked button
                document.getElementById(targetSlide).classList.add('active');
                this.classList.add('active');
                
                // Scroll to the top of the slide
                window.scrollTo({
                    top: document.getElementById(targetSlide).offsetTop - 100,
                    behavior: 'smooth'
                });
            });
        });
        
        // Handle prev/next navigation
        const prevButtons = document.querySelectorAll('.prev-btn');
        const nextButtons = document.querySelectorAll('.next-btn');
        
        prevButtons.forEach(button => {
            button.addEventListener('click', function() {
                const currentSlide = document.querySelector('.topic-slide.active');
                const currentIndex = Array.from(slides).indexOf(currentSlide);
                
                if (currentIndex > 0) {
                    // Hide current slide and show previous slide
                    currentSlide.classList.remove('active');
                    slides[currentIndex - 1].classList.add('active');
                    
                    // Update active button
                    topicButtons.forEach(btn => btn.classList.remove('active'));
                    topicButtons[currentIndex - 1].classList.add('active');
                    
                    // Scroll to the top of the slide
                    window.scrollTo({
                        top: slides[currentIndex - 1].offsetTop - 100,
                        behavior: 'smooth'
                    });
                }
            });
        });
        
        nextButtons.forEach(button => {
            button.addEventListener('click', function() {
                const currentSlide = document.querySelector('.topic-slide.active');
                const currentIndex = Array.from(slides).indexOf(currentSlide);
                
                if (currentIndex < slides.length - 1) {
                    // Hide current slide and show next slide
                    currentSlide.classList.remove('active');
                    slides[currentIndex + 1].classList.add('active');
                    
                    // Update active button
                    topicButtons.forEach(btn => btn.classList.remove('active'));
                    topicButtons[currentIndex + 1].classList.add('active');
                    
                    // Scroll to the top of the slide
                    window.scrollTo({
                        top: slides[currentIndex + 1].offsetTop - 100,
                        behavior: 'smooth'
                    });
                }
            });
        });
        
        // Handle 'Complete Chapter' buttons
        const completeButtons = document.querySelectorAll('.btn:not(.prev-btn):not(.next-btn):not([data-target]):not(.solution-btn)');
        completeButtons.forEach(button => {
            button.addEventListener('click', function() {
                // Return to the course index page
                window.location.href = 'index.html';
            });
        });
    }
    
    // Add hover effect for chapter cards
    const chapterCards = document.querySelectorAll('.chapter-card');
    chapterCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px)';
            this.style.boxShadow = '0 5px 15px rgba(0, 0, 0, 0.1)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
            this.style.boxShadow = '0 3px 10px rgba(0, 0, 0, 0.08)';
        });
    });
    
    // Handle the new slide navigation in new chapter format
    if (newSlides.length > 0) {
        // Show the first slide by default
        if (!document.querySelector('.slide.active')) {
            newSlides[0].classList.add('active');
        }
        
        // Next slide buttons
        nextSlideButtons.forEach(button => {
            button.addEventListener('click', function() {
                if (this.disabled) return;
                
                const currentSlide = document.querySelector('.slide.active');
                const currentIndex = Array.from(newSlides).indexOf(currentSlide);
                
                if (currentIndex < newSlides.length - 1) {
                    // Hide current slide and show next slide
                    currentSlide.classList.remove('active');
                    newSlides[currentIndex + 1].classList.add('active');
                    
                    // Scroll to the top of the slide
                    window.scrollTo({
                        top: 0,
                        behavior: 'smooth'
                    });
                }
            });
        });
        
        // Previous slide buttons
        prevSlideButtons.forEach(button => {
            button.addEventListener('click', function() {
                if (this.disabled) return;
                
                const currentSlide = document.querySelector('.slide.active');
                const currentIndex = Array.from(newSlides).indexOf(currentSlide);
                
                if (currentIndex > 0) {
                    // Hide current slide and show previous slide
                    currentSlide.classList.remove('active');
                    newSlides[currentIndex - 1].classList.add('active');
                    
                    // Scroll to the top of the slide
                    window.scrollTo({
                        top: 0,
                        behavior: 'smooth'
                    });
                }
            });
        });
        
        // Handle 'Complete Chapter' buttons
        const completeButtons = document.querySelectorAll('.complete-chapter');
        completeButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                // Return to the course index page
                window.location.href = 'index.html';
            });
        });
    }
});
