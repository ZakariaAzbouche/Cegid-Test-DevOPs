import { LightningElement, api } from 'lwc';

export default class Lwc_OutlookIntegration extends LightningElement {

    @api messageBody;
    @api subject;
    @api people;

    connectedCallback() {
        console.log('msg',JSON.stringify(this.messageBody))
        console.log('sub',this.subject)
        console.log('pp',JSON.stringify(this.people))
    }

}