import {Controller} from "stimulus"

const show = targets => targets.forEach(t => t.style = `display: block`)
const hide = targets => targets.forEach(t => t.style = `display: none`)

export default class extends Controller {
  static targets = ["show", "hide"]

  connect() {
    // this.outputTarget.textContent = 'Hello, Stimulus!'
    console.log("STIMULUS!")
  }

  toggle(event){
    if (event.target.checked){
      show(this.showTargets)
      hide(this.hideTargets)
    } else {
      hide(this.showTargets)
      show(this.hideTargets)
    }
  }
}
