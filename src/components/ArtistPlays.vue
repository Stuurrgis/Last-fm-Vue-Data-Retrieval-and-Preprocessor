<template>
  <div class="artistPlays">
    <h2>{{ artist }} Playcount History</h2>
    <button class="years" v-for="year in yearsActive" :key="year" v-on:click="curYear = year">{{ year }}</button>
    <div class="playcounts" v-for="date in artistFilteredResults" :key="date">
      <p>{{ date }}: {{ row[date] }} total plays</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ArtistPlays',

  data: function() {
    return {
      curYear: new Date().getFullYear(),
      years: [],
    }
  },

  props: {
    artist: String,
    headers: Array,
    row: Array,
  },

  methods: {
    computeYears() {
      this.years = []
      for (var i = 0; i < this.headers.length; ++i) {
        let year = this.headers[i].substring(4, 8)
        if (!this.years.includes(year)) {
          this.years.push(year)
        }
      }
      return;
    },
  },

  computed: {
    artistFilteredResults() {
      return this.headers.filter(month => {
        return this.row[month] != 0 && month.indexOf(this.curYear) !== -1
      })
    },
    yearsActive() {
      this.computeYears()
      return this.years.filter(year => {
        for (var i = 0; i < this.headers.length; ++i) {
          if (this.headers[i].indexOf(year) !== -1 && this.row[this.headers[i]]) {
            return true;
          }
        }
        return false;
      })
      /*this.years = []
      for (var i = 0; i < this.headers.length; ++i) {
        console.log(this.headers[i])
        let year = this.headers[i].substring(4, 8)
        console.log(year)
        if (!this.years.includes(year)) {
          this.years.push(year)
        }
      }
      return this.years*/
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#artistPlays {
  overflow-y: hidden;
}
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
.years {
  background-color: rgb(255, 74, 104);
  color: black;
  padding-left: 5px;
  padding-right: 5px;
  margin: 20px;
}
.playcounts {
  font-size: 13px;
}
</style>
