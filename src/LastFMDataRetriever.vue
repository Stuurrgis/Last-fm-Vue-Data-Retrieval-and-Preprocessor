<template>
  <div id="app">
    <img class = "logo" alt="last.fm logo" src="./assets/last_fm_logo.png">
    <transition name="fade">
      <div v-if="!entered" id="start" key="1">
        <h1>Welcome to the Last.fm Data Retriever!</h1>
        <h3>Enter Last.fm Username</h3>
        <p>(If you are here to demo the application, I suggest using Hauser1992 as a username)</p>
        <input v-model= "payload['username']" v-on:keyup.enter="onEnter()"/>
      </div>
      <div v-else-if="entered && !finished" id="processing" key="2">
        <p>Extracted {{ payload['page'] - 1 }} out of {{ totalPages }} pages!</p>
      </div>
      <div v-else-if="finished && !artistHistory" id="done" key="3">
        <h3><input type="button" v-on:click="convertToCSV" value="CSV File Ready to Download!"></h3>
        <h5>Or Search For Artists in Your History:</h5>
        <input type="text" v-model="search" placeholder="Search Artist">
        <br><br>
        <span><button class="artist" v-for="result in filteredResults" :key="result" v-on:click="changeToArtistHistory(result)">
          <pre>{{ result }}</pre>
        </button></span>
      </div>
      <div v-else-if="artistHistory" id="history" key="4">
        <ArtistPlays :artist="currArtist" :headers="dates" :row="sums[currArtist]"></ArtistPlays>
        <input type="button" v-on:click="artistHistory = false" value="Go Back">
      </div>
    </transition>
  </div>
</template>

<script>

import axios from 'axios';
import ArtistPlays from './components/ArtistPlays'

export default {
  name: 'LastFMDataRetriever',
  data: function() {
    return {
      entered: false,
      finished: false,
      searched: true,
      artistHistory: false,
      currArtist: "",
      search: "",
      lol: ' ',
      payload: {
        'method': 'user.getRecentTracks',
        'limit': 200,
        'username': ' ',
        'page': 1,
        'from': 0,
        'api_key': '57ee3318536b23ee81d6b27e36997cde',
        'format': 'json'
      },
      headers: {
        'user-agert': 'Last.fm Bar Chart Race'
      },
      totalPages: 5,
      artists: {},
      artist: [],
      dates: [],
      sums: {},
    }
  },
  components: {
    ArtistPlays,
  },
  methods: {
    sleep(ms) {
      //console.log("hey 55555")
      return new Promise(resolve => setTimeout(resolve, ms));
    },
    changeToArtistHistory(result) {
      this.artistHistory = true
      this.currArtist = result
      var sum = 0
      if (Object.prototype.hasOwnProperty.call(this.sums, result)) {
        return
      }
      this.sums[result] = []
      for (var i = 0; i < this.dates.length; ++i) {
        this.header += this.dates[i] + "  "
        if (Object.prototype.hasOwnProperty.call(this.artists[result], this.dates[i])) {
          sum += this.artists[result][this.dates[i]]
        }
        this.sums[result][this.dates[i]] = sum
      }
    },
    async onEnter() {
      this.entered = true

      
      axios.get(`http://ws.audioscrobbler.com/2.0/`, {
        params: this.payload,
        headers: this.headers,
      })
      .then(response => {
        this.totalPages = parseInt(response.data['recenttracks']['@attr']['totalPages'])
      })
      await this.sleep(300)
      for (this.payload['page']; this.payload['page'] <= this.totalPages; ++this.payload['page']) {
        //console.log(this.payload['page'])
        axios.get(`http://ws.audioscrobbler.com/2.0/`, {
          params: this.payload,
          headers: this.headers,
        })

        .then(response => {
          this.makeList(response.data)
        })

        .catch(error => {
          console.log(`ERROR: ${error}`);
          this.payload['page'] -= 1
        })

        await this.sleep(350)
      }
      await this.sleep(350)
      this.finished = true
    },
    makeList(jsonList) {
      var obj
      var artist
      var initial_date
      for (var i = 0; i < jsonList['recenttracks']['track'].length; ++i) {
        obj = jsonList['recenttracks']['track'][i]

        // If we're now playing a song, we don't add it
        if (Object.prototype.hasOwnProperty.call(obj, 'date') == false) {
          continue
        }
        artist = obj['artist']['#text']
        initial_date = obj['date']['#text'].substring(3, obj['date']['#text'].indexOf(','))

        if (initial_date.indexOf("1970") !== -1) {
          initial_date = "No Date"
        }
        //console.log(artist)
        //console.log(initial_date)
        if (Object.prototype.hasOwnProperty.call(this.artists, artist) == false) {
          this.artist.push(artist)
          this.artists[artist] = 1
          this.artists[artist] = {}
        }
        if (Object.prototype.hasOwnProperty.call(this.artists[artist], initial_date) == false) {
          this.artists[artist][initial_date] = 1
        }
        else {
          this.artists[artist][initial_date] += 1
        }
        if (!this.dates.includes(initial_date)) {
          this.dates.unshift(initial_date)
          //console.log(this.dates)
        }
      }
      return;
    },
    /*artistHistory(artistName) {
      var fullArtistHistory = ""
      if (!Object.prototype.hasOwnProperty.call(this.artists, artistName)) {
        return "You Haven't Listened to the Artist"
      }
      return "You Have Listened to " + artistName
    },*/
    convertToCSV() {
      var sum = 0
      var csv = ""
      this.dates.unshift('artist')
      for (var i = 0; i < this.dates.length; ++i) {
        if (csv !== "") {
          csv += ','
        }
        csv += this.dates[i]
      }
      csv += '\n'
      for (i = 0; i < Object.keys(this.artists).length; ++i) {
        var artist = this.artist[i]
        sum = 0
        csv += artist + ','
        for (var j = 1; j < this.dates.length; ++j) {
          if (Object.prototype.hasOwnProperty.call(this.artists[artist], this.dates[j])) {
            sum += this.artists[artist][this.dates[j]]
            //sums[artist][this.dates[j]] = sum
            csv += sum.toString()
          }
          if (j + 1 != this.dates.length) {
            csv += ','
          }
        }
        csv += '\n'
      }
      //console.log(csv)
      const anchor = document.createElement('a');
      anchor.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
      anchor.target = '_blank';
      anchor.download = this.payload['username'].concat('_History.csv');
      anchor.click();

      
      //this.dates.unshift('artist')
      //var output_filename = this.payload['user'] + "-processed.csv"
      //let csv = "Artist,Date1,Date2,Date3"
      /*this.sums.forEach((row) => {
        console.log(row)
        csv += row.join(',');
        csv += "\n"
        console.log
      })*/
    },
  },
  computed: {
    filteredResults () {
      var numSearches = 0
      return this.artist.filter(result => {
        if (this.search === "" || numSearches == 15) {
          return
        }
        if (result.toLowerCase().includes(this.search.toLowerCase())) {
          ++numSearches
          return true
        }
        //return result.toLowerCase().includes(this.search.toLowerCase())
      })
    }
  },
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
  margin-left: 60px;
  margin-right: 60px;
  overflow-y: hidden;
}
.logo {
  width: 10%;
  height: auto;
}
.fade-enter-active {
  transition: opacity .5s ease;
  transition-delay: .5s;
}
.fade-leave-active {
  transition: opacity .5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}
span .artist{
  background-color: rgb(255, 74, 104);
  color: black;
  padding-left: 5px;
  padding-right: 5px;
  margin: 20px;
}
</style>
