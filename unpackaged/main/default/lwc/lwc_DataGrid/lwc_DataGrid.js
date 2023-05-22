/* eslint-disable guard-for-in */
import { LightningElement, api, track } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
} from 'lightning/flowSupport';

import DataGridCss from '@salesforce/resourceUrl/DataGridCss';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class Lwc_DataGrid extends LightningElement {

    @api selectedRecords
    @api draftRecords
    @api records
    @api columns
    @api state
    @api buttonActionName
    @api actionName
    @api previewMode
    @api title
    @api flowMode
    @api tableIcon
    @api objectApiName
    @api displayInCard
    @api source
    @api withSelection
    @api allSelected
    @api useSearch
    @api useActions
    @api useCustomActions
    @api useUpdate
    @api useDelete
    @api useCreate
    @api noTextEllipsis
    @api actions
    @api hideMasterSelect
    @api centerHeader

    @track dataSave

    get addArticle() {
        return (this.displayInCard == 'displayInCard') ? true : false
    }

    @track draftValues = []
    @track clmns
    @track processedRecords = []
    @track colWidth
    @track headerColWidth

    connectedCallback() {

        this.customActions = (this.actions && this.useCustomActions) ? JSON.parse(this.actions) : undefined
        this.clmns = JSON.parse(this.columns);

        try{
            var visibleClmnNum = 0;
            this.clmns.forEach(clmn => {
                if(clmn.visible) {
                    visibleClmnNum += 1
                }
            })

            for(let i = 0; i <= this.records.length; i++) {

                let record = this.records[i];

                let recordCopy= {};

                for (const key in record) {
                    recordCopy[key] = record[key];
                }

                console.log(recordCopy);

                this.draftValues.push(recordCopy);
                
                let rcd = {
                    index: i,
                    Id: record.Id,
                    referenceName: this.clmns[0].objectType,
                    fields: [],
                    selected: false
                };

                this.clmns.forEach(clmn => {
                    rcd.fields.push(
                        {
                            name: clmn.value,
                            label: clmn.label,
                            value: record[clmn.value],
                            displayedValue: (clmn.list && record[clmn.value]) ? clmn.options.find(opt => opt.value == record[clmn.value]).label : record[clmn.value],
                            edit: (clmn.edit) ? clmn.edit : false,
                            controllingValues: clmn.controllingValues,
                            controllingField: clmn.controllingField,
                            controlled: clmn.controlled,
                            editable: clmn.editable,
                            clickable: (clmn.clickable) ? true : false,
                            required: (clmn.required) ? clmn.required : false,
                            type: clmn.type,
                            checkbox: (clmn.type == 'checkbox') ? true : false,
                            textarea: (clmn.type == 'textarea') ? true : false,
                            list: clmn.list,
                            numberOnly: clmn.numberOnly,
                            options: clmn.options,
                            changed: false,
                            visible: clmn.visible,
                            valueMissing: clmn.valueMissing,
                            class: (this.mobileMode) ? "div-table-col-child" : "div-table-col"
                        }
                    )
                });

                this.processedRecords.push(rcd);

            }
        } catch(e) {
            console.log(e)
        }

        console.log(JSON.stringify(this.processedRecords))
    }

    renderedCallback() {
        if(this.allSelected) {
            this.selectAll(true)
            this.allSelected = false
        }
    }

    handleClick(event) {
        this.state = event.target.name;
        this.draftRecords = this.draftValues;
        console.log(this.state)
        setTimeout(function() {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }.bind(this), 0)
    }

    editLine(event) {
        event.stopPropagation();
        this.processedRecords.find(r => r.Id == event.target.dataset.recordId || r.Id == event.currentTarget.id.substring(0, event.currentTarget.id.indexOf('-'))).fields.forEach(f => {
            f.edit = f.editable && true;
        })
    }

    closeAllEdit(event) {
        this.template.querySelector('c-lwc_-data-grid_-table').closeAllEdit()
    }

    preventPropagation(event) {
        event.preventDefault();
        event.stopPropagation();
    }

    handleSelect(event) {
        const selectEvent = new CustomEvent(
            'select', 
            { 
                detail: event.detail
            }
        );

        if(this.flowMode == 'false') {
            if(event) event.stopPropagation()
            this.dispatchEvent(selectEvent)
        }
    }

    inlineEditEvent(event) {
        this.draftRecords = event.detail.draftRecords
        this.selectedRecords = event.detail.selectedRecords
        const changeEvent = new CustomEvent(
            'change', 
            { 
                detail: event.detail.toDispatch
            }
        );

        if(this.flowMode == 'false') {
            if(event) event.stopPropagation()
            this.dispatchEvent(changeEvent)
        } else {
            if(this.flowMode) {

                if(this.selectedRecords && this.selectedRecords.length > 0) {
                    const flowChangeEvt = new FlowAttributeChangeEvent(
                        'selectedRecords',
                        this.selectedRecords
                    )
                    this.dispatchEvent(flowChangeEvt);
                }

                const flowChangeEvt = new FlowAttributeChangeEvent(
                    'draftRecords',
                    this.draftRecords
                )
                this.dispatchEvent(flowChangeEvt);
            }
        }
    }

    selectEvent(event) {
        this.selectedRecords = event.detail.selectedRecords

        if(this.flowMode) {
            const flowChangeEvt = new FlowAttributeChangeEvent(
                'selectedRecords',
                this.selectedRecords
            )
            this.dispatchEvent(flowChangeEvt);
        }

        this.processedRecords = event.detail.processedRecords
    }

    @api
    apiTriggerChange(recordId, fieldName, value, event) {
        return new Promise((resolve, reject) => {
            resolve(this.processChanges(recordId, fieldName, value, event))
        });
    }

    @api
    reportValidity() {
        return his.template.querySelector('c-lwc_-data-grid_-table').reportValidity()
    }

    handleOnselect_dispatched(event) {
        //prevent bubbling
        event.stopPropagation()
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                name: event.target.value,
                source: 'DataGrid',
                what: 'use internal command'
            }
        }))
    }

    handleClick_dispatched(event) {
        //prevent bubbling
        event.stopPropagation()
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                name: event.target.name,
                source: 'DataGrid',
                what: 'use internal command'
            }
        }))
    }

    searchHandler(event) {
        this.dataSave = JSON.parse(JSON.stringify(this.processed__records))
        delete this.processed__records
        const value = event.target.value
        this.processed__records = this.dataSave.filter(function(element) {
            for(const key in element) {
                return element[key].includes(value)
            }
        }.bind(event))   
    }

    @api
    hrefEvent(event) {
        const ev = new CustomEvent(
            'href', 
            { 
                detail: {
                    recordId: event.detail.recordId,
                    source: 'hrefClicked'
                }
            }
        )

        this.dispatchEvent(ev);
    }

}