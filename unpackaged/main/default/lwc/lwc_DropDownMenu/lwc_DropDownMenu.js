import { LightningElement, api, track } from 'lwc';

export default class Lwc_DropDownMenu extends LightningElement {

    @api options;
    @api headerLabel;
    @api required;
    @api withSearch

    @track optionsSave;
    @track currentValue = "Select...";
    @track selection;
    @track inputValue = '';

    get withHeader() {
        return (this.headerLabel == 'no-header') ? false : true;
    }

    connectedCallback() {
        this.optionsSave = this.options;
        this.currentValue = (this.options.findIndex(e => e.groupName != null) > -1) ? 
                                (this.options.find(e => e.child && e.child.find(c => c.selected == true))) ? 
                                    this.options.find(e => e.child.find(c => c.selected == true)).child.find(c => c.selected == true).label : "Select..." :
                                (this.options.find(e => e.selected == true)) ? this.options.find(e => e.selected == true).label : "Select...";
        if(this.currentValue != "Select...") {
            const selectedEvent = new CustomEvent('select', { 
                    detail: (this.options.findIndex(e => e.groupName != null) > -1) ? 
                                this.options.find(e => e.child.find(c => c.label == this.currentValue)).child.find(c => c.label == this.currentValue).value : 
                                this.options.find(e => e.label == this.currentValue).value 
            });
            this.dispatchEvent(selectedEvent);
        }
    }

    handleSelect(evt) {
        evt.stopPropagation();
        try {
            this.currentValue = (this.options.findIndex(e => e.groupName != null) > -1) ? 
                                    this.options.find(e => e.child.find(c => c.value == evt.target.value)).child.find(c => c.value == evt.target.value).label : 
                                    this.options.find(e => e.value == evt.target.value).label;
            const selectedEvent = new CustomEvent('select', { detail: evt.target.value });
            this.inputValue = this.currentValue;
            this.dispatchEvent(selectedEvent);
            this.selection = false;
            this.hideDetails();
        } catch(e) {
            console.log(e)
        }
    }

    handleUserType(evt) {
        try{
            console.log(evt.target.value);
            this.inputValue = evt.target.value;
            if(evt.target.value.length > 0) {
                if(this.options.findIndex(e => e.groupName != null) > -1) {
                    this.options.forEach(e => {
                        e.child = e.child.filter(c => c.label.toLowerCase().includes(evt.target.value.toLowerCase()) || c.value.toLowerCase().includes(evt.target.value.toLowerCase()))
                    });
                    this.optionsSave = this.options;
                } else {
                    this.optionsSave = this.options.filter(c => c.label.toLowerCase().includes(evt.target.value.toLowerCase()) || c.value.toLowerCase().includes(evt.target.value.toLowerCase()));
                }    
            } else {
                this.optionsSave = this.option;
            }
            console.log(this.optionsSave)
        } catch(e) {
            console.log(e)
        }
    }      

    detailsOpened(evt) {
        if(evt.target.hasAttribute('open')) {
            this.selection = false;
        } else {
            this.selection = true;
            setTimeout(function(){
                if(this.template.querySelector('.simple__input')) {
                    this.template.querySelector('.simple__input').focus();
                }
            }.bind(this), 1);
        }
    }

    @api
    hideDetails() {
        this.template.querySelector('details').removeAttribute("open");
    }

    get ulClass() {
        return (this.options.length == 1 && this.options[0].noValue) ? 'select-box__list no-height' : 'select-box__list height';
    }

}