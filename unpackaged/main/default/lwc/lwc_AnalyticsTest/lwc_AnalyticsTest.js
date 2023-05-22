import { LightningElement, api } from 'lwc';

import Id from '@salesforce/user/Id';

export default class Lwc_AnalyticsTest extends LightningElement {

    @api recordId

    connectedCallback() {
        console.log(Id)
        console.log(this.recordId)
    }

}