import { LightningElement, api, track } from 'lwc';
import returnSchema from '@salesforce/apex/CAP_Global_SF_SysTools.returnSchema';
import getSObjectFields from '@salesforce/apex/CAP_Global_SF_SysTools.getSObjectFields';

export default class Lwc_ComponentEditor extends LightningElement {
    @api
    inputVariables;

    @api
    genericTypeMappings;

    @api 
    builderContext;

    @track objects;
    @track fieldsInObject;
    @track flowMode = true;
    @track processById = false;
    @track processByList = true;
    @track title;
    @track records;
    @track tableIcon;
    @track buttonActionName;
    @track actionName;
    @track columns = [];
    @track previewMode = false;
    @track editMode = false;
    @track columnInstances = [];
    @track editActionName = false;
    @track withSelection
    @track allSelected
    @track useActions
    @track useSearchBar
    @track actions

    get objectApiName() {
        const type = this.genericTypeMappings.find(
            ({ typeName }) => typeName === 'T'
        );
        return type && type.typeValue;
    }

    get valueOptions() {
        try{
            return this.prepareValues(false, this.objectApiName, this.objectApiName);
        } catch(e) {
            console.log(e)
        }
    }

    get recordsOptions() {
        try{
            return this.prepareValues(true, this.objectApiName, this.records);
        } catch(e) {
            console.log(e)
        }
    }

    @track wait = {
        waitObjects: true,
        waitValuesVar: true,
        waitFields: true
    };

    prepareValues(collection, objectType, valueSelected) {
        const recordLookups = this.builderContext.recordLookups;
        const variables = this.builderContext.variables;
        const formulas = this.builderContext.formulas;
        var collectionList = [];
        var varibaleList = [];
        var formulasList = [];
        recordLookups.forEach(lookUp => {
            if(objectType && lookUp.object == objectType) {
                if(!lookUp.getFirstRecordOnly && collection) {
                    collectionList.push({
                        id: lookUp.name,
                        label: lookUp.label,
                        value: lookUp.name,
                        type: lookUp.object,
                        icon: 'utility:collection_alt',
                        selected: (valueSelected && lookUp.name == valueSelected) ? true : false
                    });
                } else if(lookUp.getFirstRecordOnly && !collection) {
                    varibaleList.push({
                        id: lookUp.name,
                        label: lookUp.label,
                        value: lookUp.name,
                        type: lookUp.object,
                        icon: 'utility:collection_alt',
                        selected: (valueSelected && lookUp.name == valueSelected) ? true : false
                    });
                }
            }
        });
        variables.forEach(variable => {
            if(objectType && variable.objectType == objectType) {
                if(variable.isCollection && collection) {
                    collectionList.push({
                        id: variable.name,
                        label: variable.name,
                        value: variable.name,
                        type: variable.objectType,
                        icon: 'utility:collection_alt',
                        selected: (valueSelected && variable.name == valueSelected) ? true : false
                    });
                } else if(!variable.isCollection && !collection) {
                    varibaleList.push({
                        id: variable.name,
                        label: variable.name,
                        value: variable.name,
                        type: variable.objectType,
                        icon: 'utility:text',
                        selected: (valueSelected && variable.name == valueSelected) ? true : false
                    });
                }
            } else {
                if(variable.isCollection && collection) {
                    collectionList.push({
                        id: variable.name,
                        label: variable.name,
                        value: variable.name,
                        type: variable.objectType,
                        icon: 'utility:collection_alt',
                        selected: (valueSelected && variable.name == valueSelected) ? true : false
                    });
                } else if(!variable.isCollection && !collection) {
                    varibaleList.push({
                        id: variable.name,
                        label: variable.name,
                        value: variable.name,
                        type: variable.objectType,
                        icon: 'utility:text',
                        selected: (valueSelected && variable.name == valueSelected) ? true : false
                    });
                }
            }
        });
        formulas.forEach(formula => {
            if(objectType && formula.objectType == objectType) {
                formulasList.push({
                    id: formula.name,
                    label: formula.name,
                    value: formula.name,
                    type: formula.objectType,
                    icon: 'utility:formula',
                    selected: false
                });
            } else {
                formulasList.push({
                    id: formula.name,
                    label: formula.name,
                    value: formula.name,
                    type: formula.objectType,
                    icon: 'utility:formula',
                    selected: false
                });
            }
        });
        this.wait.waitValuesVar = false;
        return (collectionList.length > 0 || varibaleList.length > 0 || formulasList.length > 0) ? [
            {
                id: 'collection',
                groupName: 'Collection Variables',
                child: (collectionList.length > 0) ? collectionList : null
            },
            {
                id: 'variables',
                groupName: 'Variables',
                child: (varibaleList.length > 0) ? varibaleList : null
            },
            {
                id: 'formulas',
                groupName: 'Formulas',
                child: (formulasList.length > 0) ? formulasList : null
            }
        ] : [
            {
                id: 'No value available.',
                label: 'No value available.',
                value: 'No value available.',
                noValue: true
            }
        ]
    }

    initData() {
        const newValue = 'displayInCard'
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'source',
            newValue,
            newValueDataType: 'String',
        });

        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'displayInCard',
            newValue,
            newValueDataType: 'String',
        });
    }

    connectedCallback() {

        this.initData()

        const newValue = '$GlobalConstant.True' ;
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'flowMode',
            newValue,
            newValueDataType: 'Boolean',
        });

        setTimeout(function() {
            const newValue = '$GlobalConstant.False';
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'withSelection',
                newValue,
                newValueDataType: 'Boolean'
            });
        }.bind(this), 0)

        setTimeout(function() {
            const newValue = '$GlobalConstant.False';
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'allSelected',
                newValue,
                newValueDataType: 'Boolean'
            });
        }.bind(this), 0)
            
        try {
            console.log(JSON.stringify(this.inputVariables))
            this.inputVariables.forEach(variable => {
                if(variable.name == 'previewMode') {
                    if(variable.value.includes('True')) {
                        this.previewMode = true;
                        this.editMode = false;
                    } else {
                        this.editMode = true;
                        this.previewMode = false
                    }
                } else if(variable.name == 'withSelection') {
                    this.withSelection = (variable.value.includes('True')) ? true : false
                } else if(variable.name == 'allSelected') {
                    this.allSelected = (variable.value.includes('True')) ? true : false
                } else if(variable.name == 'flowMode') {
                    if(variable.value.includes('True')) {
                        this.flowMode = true;
                    } else {
                        this.flowMode = false
                    }
                } else if(variable.name == 'columns'){
                    this.columns = JSON.parse(variable.value);
                    console.log(JSON.stringify(this.columns))
                    this.columns.forEach(clmn => {
                        this.columnInstances.push(clmn.value);
                    })
                } else if(variable.name == 'useActions') {
                    this.useActions = (variable.value.includes('True')) ? true : false
                } else if(variable.name == 'useSearchBar') {
                    this.useSearchBar = (variable.value.includes('True')) ? true : false
                } else if(variable.name == 'actions') {
                    this.actions = (variable) ? JSON.parse(variable.value) : undefined
                } else {
                    this[variable.name] = variable.value;
                }
            })
        } catch(e) {
            console.log(e)
        }

        console.log(JSON.stringify(this.columnInstances));

        returnSchema()
        .then(data => {
            try {
                this.objects = data;
                this.objects.sort((a, b) => (a.label > b.label) ? 1 : -1);
                if(this.objectApiName) {
                    this.objects.find(e => e.value == this.objectApiName).selected = true;
                }
                this.wait.waitObjects = false;
            } catch(e) {
                console.log(e)
            }
        });
    }

    handleWithSelectionChange(event) {
        const newValue = (event.target.checked) ? '$GlobalConstant.True' : '$GlobalConstant.False';
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'withSelection',
            newValue,
            newValueDataType: 'Boolean'
        });
    }

    handleAllSelectedChange(event) {
        const newValue = (event.target.checked) ? '$GlobalConstant.True' : '$GlobalConstant.False';
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'allSelected',
            newValue,
            newValueDataType: 'Boolean'
        });
    }

    handleModeChoice(event) {
        if(event.target.id.includes('flow')) {
            this.flowMode = true;
            const newValue = '$GlobalConstant.True' ;
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'flowMode',
                newValue,
                newValueDataType: 'Boolean',
            });
        } else {
            this.flowMode = false;
            const newValue = '$GlobalConstant.False';
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'flowMode',
                newValue,
                newValueDataType: 'Boolean',
            });
        }
    }

    handleFeaturesChoice(event) {
        if(event.target.id.includes('search')) {
            this.useSearchBar = event.target.checked
            const newValue = '$GlobalConstant.True' ;
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'useSearch',
                newValue,
                newValueDataType: 'Boolean',
            });
        } else if(event.target.id.includes('actions')) {
            this.useActions = event.target.checked
            const newValue = (event.target.checked) ? '$GlobalConstant.True' : '$GlobalConstant.False';
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'useActions',
                newValue,
                newValueDataType: 'Boolean',
            });
        }
    }

    handleInputTypeChange(event) {
        this.wait.waitFields = true;
        this.dispatchSettings('configuration_editor_generic_type_mapping_changed', {
            typeName: 'T',
            typeValue: event.detail
        });
        setTimeout(function() {
            getSObjectFields({sobjectName: this.objectApiName, withRef: !this.processByList})
            .then(data => {
                try {
                    if(!(this.columns.length >= 0 && this.columns)){
                        this.columns = [];
                    }
                    this.fieldsInObject = data.sort((a, b) => (a.label > b.label) ? 1 : -1);
                    this.wait.waitFields = false;
                } catch(e) {
                    console.log(e)
                }
            });
        }.bind(this), 10);
    }

    clearColumns(event) {
        delete this.columns;
    }

    handleVariableChange(event) {
        const newValue = event.detail;
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'records',
            newValue,
            newValueDataType: 'reference'
        });
    }

    handleProcessChoice(event) {
        if(event.target.checked) {
            this.processByList = false;
            this.processById = !this.processByList;
        } else {
            this.processById = false;
            this.processByList = !this.processByList;
        }
    }

    handleParentProcessInputChange(event) {
        console.log(event.target.value)
    }

    handleColumnChoice(event) {

        try{
            //this.columns = [];
            const columnsTmp = event.target.value;
            console.log(JSON.stringify(columnsTmp))
            if(columnsTmp.length < this.columns.length) {
                this.columns = this.columns.filter(e => columnsTmp.includes(e.value))
            } else if(columnsTmp.length > this.columns.length) {
                let difference = []
                columnsTmp.forEach(e => {
                    if(this.columns.findIndex(field => field.value == e) == -1) {
                        difference.push(e)
                    }
                })
                console.log(difference)
                console.log(difference.length)
                difference.forEach(field => {
                    this.columns.push(
                        this.fieldsInObject.find(e => e.value == field)
                    );
                })
            } else if(columnsTmp.length == 0) {
                delete this.columns
            }
        } catch(e) {
            console.log(e)
        }
        const newValue = JSON.stringify(this.columns);
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'columns',
            newValue,
            newValueDataType: 'String'
        });
    }

    handlechangeColumnLabel(event) {
        this.columns.find(e => e.value == event.target.name).label = event.target.value;
        const newValue = JSON.stringify(this.columns);
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'columns',
            newValue,
            newValueDataType: 'String'
        });
    }

    handlechangeColumnVisible(event) {
        this.columns.find(e => e.value == event.target.name).visible = event.target.checked;
        const newValue = JSON.stringify(this.columns);
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'columns',
            newValue,
            newValueDataType: 'String'
        });
    }

    handlechangeColumnEditable(event) {
        this.columns.find(e => e.value == event.target.name).editable = event.target.checked;
        const newValue = JSON.stringify(this.columns);
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'columns',
            newValue,
            newValueDataType: 'String'
        });
    }

    handlechangeColumnRequired(event) {
        this.columns.find(e => e.value == event.target.name).required = event.target.checked;
        const newValue = JSON.stringify(this.columns);
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'columns',
            newValue,
            newValueDataType: 'String'
        });
    }

    handlePerviewModeChoice(event) {
        if(event.target.id.includes('preview')) {
            const newValue = '$GlobalConstant.True';
            this.previewMode = true;
            this.editMode = false;
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'previewMode',
                newValue,
                newValueDataType: 'Boolean'
            });
        } else {
            const newValue = '$GlobalConstant.False';
            this.previewMode = false;
            this.editMode = true;
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'previewMode',
                newValue,
                newValueDataType: 'Boolean'
            });
        }
    }

    handleTableTitle(event){
        this.title = event.target.value;
        const newValue = this.title;
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'title',
            newValue,
            newValueDataType: 'String'
        });
    }

    handleTableIcon(event) {
        this.tableIcon = event.target.value;
        const newValue = this.tableIcon;
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'tableIcon',
            newValue,
            newValueDataType: 'String'
        });
    }

    handlebuttonActionLabel(event) {
        try{
            this.actions.find(a => a.id == event.target.dataset.id).label = event.target.value
            this.actions.find(a => a.id == event.target.dataset.id).name = event.target.value
            this.actions.find(a => a.id == event.target.dataset.id).title = event.target.value
            const newValue = JSON.stringify(this.actions);
            
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'actions',
                newValue,
                newValueDataType: 'String'
            });
        } catch(e) {
            console.log(e)
        }
    }

    handleActionNameEdit(event) {
        try{
            this.actions.find(a => a.id == event.target.dataset.id).name = event.target.value
            const newValue = JSON.stringify(this.actions);
            
            this.dispatchSettings('configuration_editor_input_value_changed', {
                name: 'actions',
                newValue,
                newValueDataType: 'String'
            });
        } catch(e) {
            console.log(e)
        }
    }

    handlebuttonActionName(event) {
        this.actionName = event.target.value.toLowerCase();
        const newValue = this.actionName;
        this.dispatchSettings('configuration_editor_input_value_changed', {
            name: 'actionName',
            newValue,
            newValueDataType: 'String'
        });
    }

    hideDetails(event) {
        this.template.querySelector('c-lwc_-drop-down-menu').hideDetails();
    }

    dispatchSettings(event , properties) {
        try{
            const typeChangedEvent = new CustomEvent(
                event,
                {
                    bubbles: true,
                    cancelable: false,
                    composed: true,
                    detail: properties,
                }
            );
            this.dispatchEvent(typeChangedEvent);
        } catch(e) {
            console.log(e)
        }
    }

    addActionsHandler(event) {
        if(this.actions) {
            this.actions.push({
                id: this.actions.length+1,
                label: '',
                name: ''
            })
        } else {
            this.actions = [{
                id: 1,
                label: '',
                name: ''
            }]
        }
    }

    actionDeleteHandler(event) {
        try {
            if(this.actions.length > 1) {
                this.actions = this.actions.splice(this.actions.findIndex(a => a.id == event.target.dataset.id), 1);
                let i = 1
                this.actions.forEach(a => {
                    a.id = i
                    i++
                })
            } else {
                delete this.actions
            }

            setTimeout(function() {
                const newValue = JSON.stringify(this.actions);
                this.dispatchSettings('configuration_editor_input_value_changed', {
                    name: 'actions',
                    newValue,
                    newValueDataType: 'String'
                });
            }.bind(this), 0)
        } catch(e) {
            console.log(e)
        }
    }

}