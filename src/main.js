import Vue from 'vue'
import LastFMDataRetriever from './LastFMDataRetriever.vue'

Vue.config.productionTip = false

new Vue({
  render: h => h(LastFMDataRetriever),
}).$mount('#app')
