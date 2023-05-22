/* eslint-disable no-shadow */
/* eslint-disable no-unused-expressions */
/* eslint-disable array-callback-return */
/* eslint-disable vars-on-top */
/* eslint-disable no-unused-vars */
/* eslint-disable consistent-return */
/* eslint-disable eqeqeq */
/* eslint-disable radix */
/* eslint-disable guard-for-in */
import { LightningElement, api, track } from 'lwc';

import DataGridCss from '@salesforce/resourceUrl/DataGridCss';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class Lwc_DataGrid_Table extends LightningElement {

    @api draftRecords
    @api selectedRecords
    @api processedRecords
    @api records
    @api columns
    @api state
    @api previewMode
    @api title
    @api flowMode
    @api tableIcon
    @api objectApiName
    @api displayInCard
    @api source
    @api withSelection
    @api noTextEllipsis
    @api hideMasterSelect
    @api centerHeader

    @track selected__records = []
    @track dataSave
    @track mobileMode
    @track fieldWidth
    @track draftValues = []
    @track clmns
    @track processed__records = []
    @track draft__records = []
    @track colWidth
    @track headerColWidth
    @track masterChecked
    @track picklistPlaceholder
    @track textWrap
    @track centerHeaderStyle

    divStyle

    get usedInPublicCommunity() {
        return (this.source === 'public') ? true : false
    }

    connectedCallback() {

        this.centerHeaderStyle = (this.centerHeader) ? 'center-header' : ''
        this.textWrap = (this.noTextEllipsis == true) ? '' : 'text-wrap'

        console.log(this.textWrap)

        const maxWidth = (this.withSelection) ? 95 : 100

        if(this.selectedRecords) {
            this.selectedRecords.forEach(sr => {
                var recordCopy= {}

                for (const key in sr) {
                    recordCopy[key] = sr[key]
                }

                this.selected__records.push(recordCopy)
            })
        }

        if(this.processedRecords) {
            this.processed__records = JSON.parse(JSON.stringify(this.processedRecords))
            // this.processedRecords.forEach(pr => {
            //     var recordCopy= {}

            //     for (const key in pr) {
            //         recordCopy[key] = pr[key]
            //     }

            //     this.processed__records.push(recordCopy)
            // })
        }

        if(this.draft__records) {
            this.draft__records.forEach(dr => {
                var recordCopy= {}

                for (const key in dr) {
                    recordCopy[key] = dr[key]
                }

                this.draft__records.push(recordCopy)
            })
        }

        if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
            this.mobileMode = true
            console.log("mobile")
        } else {
            console.log("not mobile")
        }

        this.fieldWidth = (this.mobileMode) ? 'width: 90%;' : 'width: 80%;'

        this.picklistPlaceholder = (window.navigator.language.includes('fr')) ? 'Sélectionner une valeur' : 'Select Value'

        Promise.all([
            loadStyle(this, DataGridCss)
        ])

        this.clmns = JSON.parse(this.columns)

        try{

            this.records.forEach(record => {

                var recordCopy= {};

                for (const key in record) {
                    recordCopy[key] = record[key]
                }

                this.draftValues.push(recordCopy)

            })

            let visibleClmnNum = 0
            this.clmns.forEach(clmn => {
                if(clmn.visible) {
                    visibleClmnNum += 1
                }
            })

            // this.headerColWidth = 'width: '+maxWidth/parseInt(visibleClmnNum)+'%;'
            this.headerColWidth = maxWidth/parseInt(visibleClmnNum)+'%;'

            // this.colWidth = 'width: '+100/parseInt(visibleClmnNum)+'%;'
            this.colWidth = 100/parseInt(visibleClmnNum)+'%;'

        } catch(e) {
            console.log(e)
        }

        console.log(JSON.stringify(this.processed__records))
    }

    renderedCallback() {
        if(this.allSelected) {
            this.selectAll(true)
            this.allSelected = false
        }

        if(this.template.querySelector('table')) {
            this.divStyle = 'height: '+this.template.querySelector('table').offsetHeight+'px;'
        }
    }

    editLine(event) {
        try{
            event.stopPropagation()
            this.processed__records.find(r => r.Id == event.target.dataset.recordId || r.Id == event.currentTarget.id.substring(0, event.currentTarget.id.indexOf('-'))).fields.forEach(f => {
                f.edit = f.editable && true
            })
        } catch(e) {
            console.log(e)
        }
    }

    @api
    closeAllEdit() {
        this.processed__records.forEach(record => {
            record.fields.forEach(field => {
                field.edit = false
            })
        })
    }

    preventPropagation(event) {
        event.stopPropagation()
    }

    selectAll(checked) {
        this.masterChecked = checked
        this.draftValues.forEach(r => {
            let parent = this.template.querySelector('div[data-record-id="'+r.Id+'"]')
            if(checked) {
                parent.classList.add('selectedRow')
                this.processed__records.find(record => record.Id == r.Id).selected = true
                this.selected__records = this.draftValues
            } else {
                this.selected__records = undefined
                this.processed__records.find(record => record.Id == r.Id).selected = false
                parent.classList.remove('selectedRow')
            }
        })
    }

    processChanges(recordId, fieldName, value, event) {
        try {
            let modifications = []
            var record = this.processed__records.find(r => r.Id == recordId)
            var controllingFields = []
            record.fields.forEach(f => {
                if(f.controllingField == fieldName) {
                    controllingFields.push(f)
                }
            })
            var field = record.fields.find(f => {f.value == fieldName})

            if(controllingFields.length > 0) {
                controllingFields.forEach(controllingField => {
                    var dependentValues = controllingField.controllingValues[value]
                    this.processed__records.find(r => r.Id == recordId).fields.find(field => field.name == controllingField.name).dependentValues = dependentValues
                    if(dependentValues && dependentValues.length > 1) {
                        // display message for completion
                        this.processed__records.find(r => r.Id == recordId).fields.find(field => field.name == controllingField.name).value = 'Liste de choix à l\'étape suivante'
                        modifications.push({
                            recordId: recordId,
                            value: 'Liste de choix à l\'étape suivante',
                            field: controllingField.name
                        })
                    } else if(dependentValues && dependentValues.length == 1) {
                        this.processed__records.find(r => r.Id == recordId).fields.find(field => field.name == controllingField.name).value = dependentValues[0].value
                        this.draftValues.find(r => r.Id == recordId)[controllingField.name] = dependentValues[0].value
                        if(this.selected__records && this.selected__records.length > 0) {
                            if(this.selected__records.find(r => r.Id == recordId))
                                this.selected__records.find(r => r.Id == recordId)[controllingField.name] = dependentValues[0].value
                        }
                        modifications.push({
                            recordId: recordId,
                            value: dependentValues[0].value,
                            field: controllingField.name
                        })
                    } else {
                        this.processed__records.find(r => r.Id == recordId).fields.find(field => field.name == controllingField.name).value = ''
                        this.draftValues.find(r => r.Id == recordId)[controllingField.name] = ''
                        if(this.selected__records && this.selected__records.length > 0) {
                            if(this.selected__records.find(r => r.Id == recordId))
                                this.selected__records.find(r => r.Id == recordId)[controllingField.name] = ''
                        }
                        modifications.push({
                            recordId: recordId,
                            value: '',
                            field: controllingField.name
                        })
                    }
                })
            }

            this.processed__records.find(r => r.Id == recordId).fields.find(field => field.name == fieldName).value = value    
            modifications.push({
                recordId: recordId,
                value: value,
                field: fieldName
            })

            this.processed__records.find(r => r.Id == recordId).isChanged = true
            this.processed__records.find(r => r.Id == recordId).fields.find(field => field.name == fieldName).displayedValue = (this.processed__records.find(r => r.Id == recordId).fields.find(field => field.name == fieldName).list) ? this.processed__records.find(r => r.Id == recordId).fields.find(field => field.name == fieldName).options.find(opt => opt.value == value).label : value   

            let draft = JSON.parse(JSON.stringify(this.draftValues.find(r => r.Id == recordId))) //... deep clone object
            draft[fieldName] = value
            this.draftValues[this.draftValues.findIndex(r => r.Id == recordId)] = draft

            return {
                changes: [...modifications],
                processedRecords: this.processed__records
            }

        } catch(e) {
            console.log(e)
        }
    }

    // Dispatchable methods
    handleInlineEdit(event) {
        const value = (event.target.dataset.type && event.target.dataset.type == 'checkbox') ? event.target.checked : event.target.value
        this.draftValues.find(record => record.Id == event.target.dataset.recordId)[event.target.dataset.fieldName] = value
        if(this.selected__records && this.selected__records.length > 0) {
            if(this.selected__records.find(record => record.Id == event.target.dataset.recordId))
                this.selected__records.find(record => record.Id == event.target.dataset.recordId)[event.target.dataset.fieldName] = value
        }
        let details = this.processChanges(event.target.dataset.recordId, event.target.dataset.fieldName, value, event)
        const changeEvent = new CustomEvent(
            'change', 
            { 
                detail: {
                    toDispatch: details,
                    draftRecords: this.draftValues,
                    selectedRecords: this.selected__records
                }
            }
        )

        if(this.flowMode == 'false') {
            if(event) event.stopPropagation()
            this.dispatchEvent(changeEvent)
        }
    }

    handleSelect(event) {
        const checked = event.target.checked

        if(event.target.name == 'master') {
            this.selectAll(checked)
        } else if(event.target.name == 'single') {
            
            if(!this.selected__records) this.selected__records = []

            const recordId = event.target.dataset.recordId
            const record = this.draftValues.find(r => r.Id == recordId)
            let parent = this.template.querySelector('div[data-record-id="'+recordId+'"]')
            if(checked) {
                parent.classList.add('selectedRow')
                this.selected__records.push(record)
                this.processed__records.find(record => record.Id == recordId).selected = true
            } else {
                const index = this.selected__records.indexOf(record)
                parent.classList.remove('selectedRow')
                if(index > -1) {
                    this.selected__records.splice(index, 1)
                }
                if(this.selected__records.length == 0) {
                    this.selected__records = undefined
                }
                this.processed__records.find(record => record.Id == recordId).selected = false
            }
        }
        
        console.log(this.selected__records)

        this.masterChecked = this.processed__records.every(r => r.selected)

        const selectEvent = new CustomEvent(
            'select', 
            { 
                detail: {
                    selectedRecords: this.selected__records,
                    processedRecords: this.processedRecords
                }
            }
        )

        if(this.flowMode == 'false') {
            if(event) event.stopPropagation()
            this.dispatchEvent(selectEvent)
        }
    }
    //

    @api
    apiTriggerChange(recordId, fieldName, value, event) {
        return new Promise((resolve, reject) => {
            resolve(this.processChanges(recordId, fieldName, value, event))
        })
    }

    @api
    reportValidity() {
        var datagrid_combobox = [...this.template.querySelectorAll('lightning-combobox')]
        var datagrid_comboboxValidity = true
        if(datagrid_combobox && datagrid_combobox.length > 0) {
            for(let input of datagrid_combobox) {
                if(datagrid_comboboxValidity && !input.reportValidity()) {
                    datagrid_comboboxValidity = false
                    break
                }
            }
        }
        return datagrid_comboboxValidity
    }

    @api
    clicked(event) {
        const ev = new CustomEvent(
            'href', 
            { 
                detail: {
                    recordId: event.target.dataset.hrefRid,
                    source: 'hrefClicked'
                }
            }
        )

        this.dispatchEvent(ev);
    }

    handleDown(event) {
        this.curCol = event.target.parentElement
        this.pageX = event.pageX
        this.curColWidth = this.curCol.offsetWidth

        console.log(JSON.stringify(this.curCol))
        console.log(this.pageX)
        console.log(this.curColWidth)
    }

    handleResize(event) {
        if (this.curCol) {
            var diffX = event.pageX - this.pageX;
            console.log(diffX)
            this.curCol.style.width = (this.curColWidth + diffX)+'px';
        }         
    }

    handleUp(event) {
        delete this.curCol
        delete this.pageX
        delete this.curColWidth
    }

}