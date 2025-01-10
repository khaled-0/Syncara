import './assets/main.css'

import { createApp } from 'vue'
import VueLazyLoad from 'vue3-lazyload'
import App from './App.vue'

createApp(App)
.use(VueLazyLoad, {
  observerOptions: {
    rootMargin: '0px',
    threshold: 0.1
  }
})
.mount('#app')
