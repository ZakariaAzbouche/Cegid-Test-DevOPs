/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * @last created on  : 28/04/2022
**/
import { LightningElement, track, wire,api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CUSTOMER_REQUEST_OBJECT from '@salesforce/schema/CustomerRequest__c';
import { loadStyle } from 'lightning/platformResourceLoader';
import customerRequestsFormStyle from '@salesforce/resourceUrl/customerRequestsFormStyle';
import ARROWPAGINATION from '@salesforce/resourceUrl/arrowPagination';
import ARROWDOWN from '@salesforce/resourceUrl/arrowdown';
import getDomainPicklist from '@salesforce/apex/CustomerRequestsFormController.getDomainPicklist';
import getInvoiceLinesData from '@salesforce/apex/CustomerRequestsFormController.getInvoiceLinesData';
import getSubscriptionLinesData from '@salesforce/apex/CustomerRequestsFormController.getSubscriptionLinesData';
import getBUExternalId from '@salesforce/apex/CustomerRequestsFormController.getBUExternalId';
import getBUIdByExternalId from '@salesforce/apex/CustomerRequestsFormController.getBUIdByExternalId';
import saveLines from '@salesforce/apex/CustomerRequestsFormController.saveLines';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/*custom settings*/
import getOffset from '@salesforce/apex/CustomerRequestsFormController.getOffset';

/* Labels */
import CUSTOMERREQUESTFORMERROR from '@salesforce/label/c.CustomerRequestFormError';
import CUSTOMERREQUESTFORMNODATA from '@salesforce/label/c.CustomerRequestFormNoData';
import CUSTOMERREQUESTFORMWSERROR from '@salesforce/label/c.CustomerRequestFormWSError';
import CUSTOMERREQUESTFORMSAVEERROR from '@salesforce/label/c.CustomerRequestFormSaveError';
import CUSTOMERREQUESTFORMNODMOREDATA from '@salesforce/label/c.CustomerRequestFormNoMoreData';
import CUSTOMERREQUESTFORMAMOUNTWARNING from '@salesforce/label/c.CustomerRequestFormAmountWarning';
import CUSTOMERREQUESTFORMLINESREQUIRED from '@salesforce/label/c.CustomerRequestFormLinesRequired';
import CUSTOMERREQUESTFORMDATEWARNING from '@salesforce/label/c.CustomerRequestFormDateWarning';
import CUSTOMERREQUESTFORMSUCCESS from '@salesforce/label/c.CustomerRequestFormSuccess';
import CUSTOMERREQUESTFORMREQUIRED from '@salesforce/label/c.CustomerRequestFormRequired';
import CUSTOMERREQUESTFORMPOPUP from '@salesforce/label/c.CustomerRequestFormPopup';
import CUSTOMERREQUESTFORMINPUTACCOUNT from '@salesforce/label/c.CustomerRequestFormInputAccount';
import CUSTOMERREQUESTFORMCOLUMNINVOICELINENUM from '@salesforce/label/c.CustomerRequestFormColumnInvoiceLineNum';
import CUSTOMERREQUESTFORMCOLUMNSUBSCRIPTIONNUM from '@salesforce/label/c.CustomerRequestFormColumnSubscriptionNum';
import CUSTOMERREQUESTFORMCOLUMNPRODUCT from '@salesforce/label/c.CustomerRequestFormColumnProduct';
import CUSTOMERREQUESTFORMCOLUMNAMOUNT from '@salesforce/label/c.CustomerRequestFormColumnAmount';
import CUSTOMERREQUESTFORMCOLUMNDATE from '@salesforce/label/c.CustomerRequestFormColumnDate';
import CUSTOMERREQUESTFORMCOLUMNTHIRDPARTY from '@salesforce/label/c.CustomerRequestFormColumnThirdParty';
import CUSTOMERREQUESTFORMCOLUMNCALCULATEDBU from '@salesforce/label/c.CustomerRequestFormColumnCalculatedBU';
import CUSTOMERREQUESTFORMCOLUMNSTARTDATE from '@salesforce/label/c.CustomerRequestFormColumnStartDate';
import CUSTOMERREQUESTFORMCOLUMNENDDATE from '@salesforce/label/c.CustomerRequestFormColumnEndDate';
import CUSTOMERREQUESTFORMCOLUMNNEXTDATERENEWAL from '@salesforce/label/c.CustomerRequestFormColumnNextDateRenewal';

export default class CustomerRequestsForm extends LightningElement {
    connectedCallback() {
        this.checked = true;
        this.showInvoiceInputs = true;
        this.showSearchedResult = true;
        this.nextButton=true;

        loadStyle(this, customerRequestsFormStyle);
        getDomainPicklist()
            .then(result => {
                var tempDomainGlobalPicklist = new Map();
                for (var key in result) {
                    tempDomainGlobalPicklist.set(key, result[key]);
                }
                this.domainGlobalPicklist = tempDomainGlobalPicklist;
            })
            .catch(error => {
                console.log(error);
            })
    }
    CustomerRequestFormError = CUSTOMERREQUESTFORMERROR;
    CustomerRequestFormNoData = CUSTOMERREQUESTFORMNODATA;
    CustomerRequestFormWSError = CUSTOMERREQUESTFORMWSERROR;
    CustomerRequestFormSaveError = CUSTOMERREQUESTFORMSAVEERROR;
    CustomerRequestFormNoMoreData = CUSTOMERREQUESTFORMNODMOREDATA;
    CustomerRequestFormLinesRequired = CUSTOMERREQUESTFORMLINESREQUIRED;
    CustomerRequestFormAmountWarning = CUSTOMERREQUESTFORMAMOUNTWARNING;
    CustomerRequestFormDateWarning = CUSTOMERREQUESTFORMDATEWARNING;
    CustomerRequestFormSuccess = CUSTOMERREQUESTFORMSUCCESS;
    CustomerRequestFormRequired = CUSTOMERREQUESTFORMREQUIRED;
    CustomerRequestFormPopup = CUSTOMERREQUESTFORMPOPUP;
    CustomerRequestFormInputAccount = CUSTOMERREQUESTFORMINPUTACCOUNT;
    CustomerRequestFormColumnInvoiceLineNum = CUSTOMERREQUESTFORMCOLUMNINVOICELINENUM;
    CustomerRequestFormColumnSubscriptionNum=CUSTOMERREQUESTFORMCOLUMNSUBSCRIPTIONNUM;
    CustomerRequestFormColumnProduct = CUSTOMERREQUESTFORMCOLUMNPRODUCT;
    CustomerRequestFormColumnAmount = CUSTOMERREQUESTFORMCOLUMNAMOUNT;
    CustomerRequestFormColumnDate = CUSTOMERREQUESTFORMCOLUMNDATE;
    CustomerRequestFormColumnThirdParty = CUSTOMERREQUESTFORMCOLUMNTHIRDPARTY;
    CustomerRequestFormColumnCalculatedBU = CUSTOMERREQUESTFORMCOLUMNCALCULATEDBU;
    CustomerRequestFormColumnStartDate = CUSTOMERREQUESTFORMCOLUMNSTARTDATE;
    CustomerRequestFormColumnEndDate = CUSTOMERREQUESTFORMCOLUMNENDDATE;
    CustomerRequestFormColumnNextDateRenewal = CUSTOMERREQUESTFORMCOLUMNNEXTDATERENEWAL;
    arrowPagination = ARROWPAGINATION;
    arrowdown = ARROWDOWN;
    @track isModalOpen = false;
    @track showLoadingSpinner = false;
    @track showSuccessToast = false;
    @track showWarningToast = false;
    @track showErrorToast = false;
    @track warningAmounts = false;
    @track warningDates = false;
    @track buOfferMultiple = false;
    @track customerRequestId = '';
    @track successTxt = '';
    @track warningText = '';
    @track accountId;
    @track techManual;//tech_ManualCreation__c
    @track erpNumber;
    @track erpNumberMissing = 'requiredfield';
    @track currencyIsoCode ='EUR';
    @track origine;
    @track origineMissing = 'requiredfield';
    @track customerRequestType;
    @track creditNoteReason1;
    @track creditNoteReason1Missing = 'requiredfield';
    @track creditNoteReason2;
    @track creditNoteReason2Missing = 'requiredfield';
    @track creditNoteReason3;
    @track creditNoteReason3Missing = 'requiredfield';
    @track cancellationReason1;
    @track cancellationReason1Missing = 'requiredfield';
    @track cancellationReason2;
    @track cancellationReason2Missing = 'requiredfield';
    @track businessUnit;
    @track businessUnitExternalId;
    @track businessUnit1;
    @track businessUnit2;
    @track businessUnit3;
    @track businessUnit4;
    @track businessUnit5;
    @track agency;
    @track agencyMissing = 'requiredfield';
    @track comment;
    @track commentMissing = 'requiredfield';
    @track domain;
    @track domainMissing = 'requiredfield';
    @track domainIndex;
    @track domainGlobalPicklist;
    @track subsidiary = 'CEGID SA';
    @track contractNumber;
    @track invoiceNumber;
    @track amountMin;
    @track amountMax;
    @track dateMin;
    @track dateMax;
    @track tierslivre;
    @track selectedItemsNames = [];
    @track selectedParents = [];
    @track invoiceLines = []; // Invoices Lines Or Subscriptions Lines (depends on Type)
    @track mapinvoiceLines = new Map();
    @track invoiceNameSet = new Set();
    @track oldJson = [];
    @track linesToSave;
    @track invoicesLinesToSave;
    @track showStep2 = false;
    @track step1Style = 'display:block;'
    @track showInvoicesLines = false;
    @track showInvoiceInputs = false;
    @track showBusinessUnit = false;
    @track showSubscriptionInputs = false;
    @track showCancellationInputs = false;
    @track showSubscriptionsWithInvoices = false;
    @track offset = 0;
    @track fieldsInfo;
    @track showDateAmount=true;
    @track showCreditNotes=true;
    @track showSubscriptionLabel=false;

    @wire(getObjectInfo, { objectApiName: CUSTOMER_REQUEST_OBJECT })
    getCustomerRequestInfo(result) {
        if (result.data)
            this.fieldsInfo = result.data.fields;
    }
    @track invoiceNumList=[];
    @track invoiceNumSearchList=[];
    @track checked = true;
    @track showSearchedResult=false;

    /*retrieve offset from cs*/
    offsetCs;
    @wire(getOffset)
    wiredOffset({ error, data }) {
        if (data) {
            this.offsetCs = data;
            console.log("custom setting offset value ",data);
        } else if (error) {
            console.error(error);
        }
    }

    //Form
    handleGetCheckedLinesStep2(event) {
        this.invoicesLinesToSave = event.detail.linestosave;
        this.buOfferMultiple = event.detail.buoffermultiple;
        if (event.detail.businessunit1 != '') {
            this.businessUnit1 = event.detail.businessunit1;
        }
        if (event.detail.businessunit2 != '') {
            this.businessUnit2 = event.detail.businessunit2;
        }
        if (event.detail.businessunit3 != '') {
            this.businessUnit3 = event.detail.businessunit3;
        }
        if (event.detail.businessunit4 != '') {
            this.businessUnit4 = event.detail.businessunit4;
        }
        if (event.detail.businessunit5 != '') {
            this.businessUnit5 = event.detail.businessunit5;
        }
        this.showModal();
    }
    handleCancelStep2() {
        this.showStep2 = false;
        this.step1Style = 'display:block;';
    }
    validateFields() {
        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }
    handleSubmit(event) {
         // If all fields aren't validated, throw error message
         console.log('handleSubmit');
         console.log('handleSubmit customerRequestId',this.customerRequestId);
            if (!this.validateFields()) {
                const toast = new ShowToastEvent({
                    message: "Review all error messages below to correct your data.",
                    variant: "error",
                });
                this.dispatchEvent(toast);
            }
            // Otherwise submit save
            else {
                this.template.querySelector("lightning-record-edit-form").submit();
                const toastEvent = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'Customer Request has been created',
                    variant: 'success',
                });
                this.dispatchEvent(toastEvent);
            }
    }

    handleSuccess(event) {
        this.customerRequestId = event.detail.id;
        console.log('handleSuccess');
        console.log('handleSuccess this.customerRequestId',this.customerRequestId);

        if(this.checked == false){

                setTimeout(() => {
                    window.location.href = "/lightning/r/CustomerRequest__c/" + this.customerRequestId + "/view";
                }, 1000);
            
        }else{

            if (this.showInvoicesLines) {
                this.saveLines(this.linesToSave, 'InvoiceLine', false);
            }
            else if (this.showSubscriptionInputs) {
                this.saveLines(this.linesToSave, 'SubscriptionLine', false);
            } else if (this.showSubscriptionsWithInvoices) {
                this.saveLines(this.linesToSave, 'SubscriptionLine', true);
            }
        }


    }

    handleError(event) {
        this.showLoadingSpinner = false;
        console.log("Error : ", JSON.stringify(event.detail));
    }
    handleTypeChange(event) {
        this.customerRequestType = event.target.value;
        console.log("handle type",this.customerRequestType);
        if (this.customerRequestType == 'Credit Note'  && this.checked == true) {//auto
            this.showInvoiceInputs = true;
            this.showInvoicesLines = true;
            this.showSubscriptionInputs = false;
            this.showCancellationInputs = false;
            this.showSubscriptionsWithInvoices = false;
            this.showDateAmount=true;
            this.showCreditNotes=true;
            this.showSubscriptionLabel=false;
        } else  if (this.customerRequestType == 'Credit Note'  && this.checked == false) {//manual
            this.showInvoiceInputs = false;
            this.showInvoicesLines = true;
            this.showSubscriptionInputs = false;
            this.showCancellationInputs = false;
            this.showSubscriptionsWithInvoices = false;
            this.showDateAmount=true;
            this.showCreditNotes=true;
            this.showSubscriptionLabel=false;
        } else if (this.customerRequestType == 'Cancellation' && this.checked == true) {//auto
            this.showInvoiceInputs = true;
            this.showInvoicesLines = false;
            this.showSubscriptionInputs = true;
            this.showCancellationInputs = true;
            this.showSubscriptionsWithInvoices = false;
            this.showDateAmount=false;
            this.showCreditNotes=false;
            this.showSubscriptionLabel=true;
        }else if(this.customerRequestType == 'Cancellation' && this.checked == false) {//manual
            this.showInvoiceInputs = false;
            this.showInvoicesLines = false;
            this.showSubscriptionInputs = true;
            this.showCancellationInputs = true;
            this.showSubscriptionsWithInvoices = false;
            this.showDateAmount=false;
            this.showCreditNotes=false;
            this.showSubscriptionLabel=true;
        } else if (this.customerRequestType == 'Cancellation with Credit Note'  && this.checked == true) {//auto
            this.showInvoiceInputs = true;
            this.showInvoicesLines = false;
            this.showSubscriptionInputs = false;
            this.showCancellationInputs = true;
            this.showSubscriptionsWithInvoices = true;
            this.showSubscriptionLabel=true;
        } else {
            this.showInvoiceInputs = false;
            this.showInvoicesLines = false;
            this.showSubscriptionInputs = false;
            this.showCancellationInputs = false;
            this.showSubscriptionsWithInvoices = false;
            this.showDateAmount=true;
            this.showSubscriptionLabel=false;
        }
    }
    handleAccountChange(event) {
        var erpNumberValue = event.detail.label;
        if (erpNumberValue) {
            this.erpNumber = erpNumberValue;
            this.accountId = event.detail.value;
            this.erpNumberMissing = 'requiredfield';
        } else {
            this.erpNumber = null;
            this.accountId = null;
        }
    }
    handleCurrencyIsoCodeChange(event) {
        this.currencyIsoCode = event.target.value;
    }
    handleCreditNoteReason1Change(event) {
        this.creditNoteReason1 = event.target.value;
        this.creditNoteReason1Missing = 'requiredfield';
    }
    handleCreditNoteReason2Change(event) {
        this.creditNoteReason2 = event.target.value;
        this.creditNoteReason2Missing = 'requiredfield';
    }
    handleCreditNoteReason3Change(event) {
        this.creditNoteReason3 = event.target.value;
        this.creditNoteReason3Missing = 'requiredfield';
    }
    handleCancellationReason1Change(event) {
        this.cancellationReason1 = event.target.value;
        this.cancellationReason1Missing = 'requiredfield';
    }
    handleCancellationReason2Change(event) {
        this.cancellationReason2 = event.target.value;
        this.cancellationReason2Missing = 'requiredfield';
    }
    handleBusinessUnitChange(event) {
        var buId = event.target.value;
        this.businessUnit1 = buId;
        if (buId) {
            getBUExternalId({ buId: buId })
                .then((result) => {
                    this.businessUnit = result.Name;
                    this.businessUnitExternalId = result.API_Code__c;
                })
                .catch((error) => {
                    console.log(error);
                    this.showErrorToast = true;
                    setTimeout(() => {
                        this.showErrorToast = false;
                    }, 3000);
                });
        } else {
            this.businessUnit = null;
            this.businessUnitExternalId = null;
        }
    }
    handleAgencyChange(event) {
        this.agency = event.target.value;
        this.agencyMissing = 'requiredfield';
    }
    handleCommentChange(event) {
        this.comment = event.target.value;
        this.commentMissing = 'requiredfield';
    }
    handleDomainChange(event) {
        var tempDomainGlobalPicklist = this.domainGlobalPicklist;
        this.domain = tempDomainGlobalPicklist.get(event.target.value);

        /////////// Delete this part //////////////////////////////////
        console.log("handleDomainChange domain before : ", this.domain);
        if (this.domain == "Professional services") this.domain = "Professional Services";
        console.log("handleDomainChange domain after : ", this.domain);
        ///////////////////////////////////////////////////////////////

        this.domainIndex = event.target.value;
        this.domainMissing = 'requiredfield';
    }
    handleSubsidiaryChange(event) {
        this.subsidiary = event.target.value;
    }
    handleContractNumber(event) {
        this.contractNumber = event.target.value;
    }
    handleInvoiceNumber(event) {
        this.invoiceNumber = event.target.value;
        this.addPillItem();
       // this.invoiceNumber = '';// to clear the field when loosing focus
    }

    addPillItem(){
        if(this.invoiceNumber !== ''){
            var item = {
                label: this.invoiceNumber
            };
            this.invoiceNumList.push(item);
            this.invoiceNumSearchList.push(this.invoiceNumber);
        }
        this.clearInvoiceNumberOnblur();

    }

    clearInvoiceNumberOnblur() {
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => { this.invoiceNumber = '';}, 0); 
    }

    removePillItem(event) {
        const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
        const itempill = this.invoiceNumSearchList;
        itempill.splice(pillIndex, 1);       
        this.invoiceNumSearchList = [...itempill];

        const pillIndex2 = event.detail.index ? event.detail.index : event.detail.name;
        const itempill2 = this.invoiceNumList;
        itempill2.splice(pillIndex2, 1);       
        this.invoiceNumList = [...itempill2];
    }

    handleOrigineChange(event) {
        this.origine = event.target.value;
        this.origineMissing = 'requiredfield';
    }
    handleAmountMinChange(event) {
        this.amountMin = event.target.value;
        this.compareAmounts();
    }
    handleAmountMaxChange(event) {
        this.amountMax = event.target.value;
        this.compareAmounts();
    }
    compareAmounts() {
        if (this.amountMin && this.amountMax && parseFloat(this.amountMin) > parseFloat(this.amountMax)) {
            this.warningAmounts = true;
            this.showWarningToast = true;
            this.warningText = this.CustomerRequestFormAmountWarning;//MSG : The Min Amount must be less than the Max Amount
            setTimeout(() => {
                this.showWarningToast = false; this.warningText = '';
            }, 2500);
        } else {
            this.warningText = '';
            this.warningAmounts = false;
        }
    }
    handleDateMinChange(event) {
        this.dateMin = event.target.value;
        this.compareDates();
    }
    handleDateMaxChange(event) {
        this.dateMax = event.target.value;
        this.compareDates();
    }
    handleTierslivreChange(event) {
        this.tierslivre = event.target.value;
    }
    compareDates() {
        if (this.dateMin && this.dateMax && this.dateMin > this.dateMax) {
            this.warningDates = true;
            this.showWarningToast = true;
            this.warningText = this.CustomerRequestFormDateWarning;
            setTimeout(() => {
                this.showWarningToast = false; this.warningText = '';
            }, 2500);
        } else {
            this.warningText = '';
            this.warningDates = false;
        }
    }
    saveStep1() {
        console.log("saveStep1 clicked");
        this.getSelectedIputs();

        if (this.selectedItemsNames.length > 0) {
            if (this.showInvoicesLines) {
                if (this.creditNoteReason1 && this.creditNoteReason2 && this.creditNoteReason3 && this.agency && this.comment && this.erpNumber && this.currencyIsoCode && this.domain && this.subsidiary) {
                    this.getCheckedLines();
                } else {
                    this.showRequiredWarning();
                }
            } else if (this.showSubscriptionInputs) {
                if (this.cancellationReason1 && this.cancellationReason2 && this.agency && this.comment && this.erpNumberrpNumber && this.currencyIsoCode && this.subsidiary) {
                    this.getCheckedLines();
                } else {
                    this.showRequiredWarning();
                }
            } else if (this.showSubscriptionsWithInvoices) {
                if (this.agency && this.comment && this.erpNumber && this.currencyIsoCode && this.subsidiary) {
                    this.getCheckedLines();
                } else {
                    this.showRequiredWarning();
                }
            } else {showRequiredWarning
                this.showRequiredWarning();
            }
        } else {
            if (this.warningText == '') {
                this.warningText = this.CustomerRequestFormLinesRequired;
                this.showWarningToast = true;
                setTimeout(() => {
                    this.showWarningToast = false; this.warningText = '';
                }, 2500);
            }
        }
    }
    showRequiredWarning() {
        window.scrollTo(0, 0);
        this.warningText = this.CustomerRequestFormRequired;
        this.showWarningToast = true;
        if (!this.creditNoteReason1) {
            this.creditNoteReason1Missing = 'requiredfield missing';
        }
        if (!this.creditNoteReason2) {
            this.creditNoteReason2Missing = 'requiredfield missing';
        }
        if (!this.creditNoteReason3) {
            this.creditNoteReason3Missing = 'requiredfield missing';
        }
        if (!this.cancellationReason1) {
            this.cancellationReason1Missing = 'requiredfield missing';
        }
        if (!this.cancellationReason2) {
            this.cancellationReason2Missing = 'requiredfield missing';
        }
        if (!this.agency) {
            this.agencyMissing = 'requiredfield missing';
        }
        if (!this.comment) {
            this.commentMissing = 'requiredfield missing';
        }
        setTimeout(() => {
            this.showWarningToast = false; this.warningText = '';
        }, 2500);
    }
    showModal() {
        this.isModalOpen = true;
    }

    clickSave() {
        const btn = this.template.querySelector(".hiddenbtn");
        this.showLoadingSpinner = true;
        btn.click();
    }

    clickManualSave(){
        const btn = this.template.querySelector(".hiddenbtn");
        this.showLoadingSpinner = true;
        this.showSuccessToast = true;
        this.successTxt = this.CustomerRequestFormSuccess;
        btn.click();
    }


    
    closeModal() {
        this.isModalOpen = false;
    }
    cancel() {
        window.location.href = "/lightning/o/CustomerRequest__c/list?filterName=Recent";
    }
    getCheckedLines() {
        this.isModalOpen = false;
        var linesToSave = [];
        var currentItem;
        var tempMapinvoiceLines = this.mapinvoiceLines;
        var tempMapBU = new Map();
        this.selectedItemsNames.forEach(function (item) {
            currentItem = tempMapinvoiceLines.get(item);
            linesToSave.push(currentItem);
            if (tempMapBU.get(currentItem.buOffer)) {
                tempMapBU.set(currentItem.buOffer, parseFloat(tempMapBU.get(currentItem.buOffer)) + parseFloat(currentItem.amount));
            } else {
                tempMapBU.set(currentItem.buOffer, parseFloat(currentItem.amount));
            }
        })
        tempMapBU = new Map([...tempMapBU.entries()].sort((a, b) => b[1] - a[1]));
        let mapKeys = [...tempMapBU.keys()];
        this.buOfferMultiple = false;
        getBUIdByExternalId({ ExternalIds: mapKeys })
            .then((result) => {
                let mapResult = Object.values(result);
                let buArray = ['', '', '', '', '']
                mapResult.forEach(function (externalBU) {
                    let i = 0;
                    tempMapBU.forEach((key, value) => {
                        if (value == externalBU.API_Code__c) {
                            buArray[i] = externalBU.Id;
                        }
                        i += 1;
                    });
                });
                if (buArray[0] != '') {
                    this.businessUnit1 = buArray[0];
                }
                if (buArray[1] != '') {
                    this.businessUnit2 = buArray[1];
                    this.buOfferMultiple = true;
                }
                if (buArray[2] != '') {
                    this.businessUnit3 = buArray[2];
                }
                if (buArray[3] != '') {
                    this.businessUnit4 = buArray[3];
                }
                if (buArray[4] != '') {
                    this.businessUnit5 = buArray[4];
                }
            })
            .catch((error) => {
                console.log(error);
                this.showErrorToast = true;
                setTimeout(() => {
                    this.showErrorToast = false;
                }, 3000);
            });
        this.linesToSave = linesToSave;
        if (this.showSubscriptionsWithInvoices) {
            this.showStep2 = true;
            this.step1Style = 'display:none;';
        } else {
            this.showModal();
        }
    }
    showManualForm(){

        this.warningText = this.CustomerRequestFormRequired;
        this.showWarningToast = true;
        if (!this.creditNoteReason1) {
            this.creditNoteReason1Missing = 'requiredfield missing';
        }
        if (!this.creditNoteReason2) {
            this.creditNoteReason2Missing = 'requiredfield missing';
        }
        if (!this.creditNoteReason3) {
            this.creditNoteReason3Missing = 'requiredfield missing';
        }
        if (!this.cancellationReason1) {
            this.cancellationReason1Missing = 'requiredfield missing';
        }
        if (!this.cancellationReason2) {
            this.cancellationReason2Missing = 'requiredfield missing';
        }
        if (!this.agency) {
            this.agencyMissing = 'requiredfield missing';
        }
        if (!this.comment) {
            this.commentMissing = 'requiredfield missing';
        }
        setTimeout(() => {
            this.showWarningToast = false; this.warningText = '';
        }, 2500);

        if(this.customerRequestType == "Credit Note" && this.creditNoteReason1 
                                                     && this.creditNoteReason2 
                                                     && this.creditNoteReason3 
                                                     && this.origine 
                                                     && this.agency 
                                                     && this.comment 
                                                     && this.accountId 
                                                     && this.erpNumber 
                                                     && this.currencyIsoCode 
                                                     && this.domain 
                                                     && this.subsidiary)
        {
            this.showModal();
            this.showWarningToast = false;
            this.showLoadingSpinner = true;
        }else if(this.customerRequestType == "Cancellation" && this.cancellationReason1 
                                                            && this.cancellationReason2 
                                                            && this.origine 
                                                            && this.agency 
                                                            && this.comment 
                                                            && this.accountId 
                                                            && this.erpNumber 
                                                            && this.currencyIsoCode 
                                                            && this.domain 
                                                            && this.subsidiary)
        {
            this.showModal();
            this.showWarningToast = false;
            this.showLoadingSpinner = true;
        }else if(this.customerRequestType == "Cancellation with Credit Note" && this.creditNoteReason1 
                                                                             && this.creditNoteReason2 
                                                                             && this.creditNoteReason3 
                                                                             && this.cancellationReason1 
                                                                             && this.cancellationReason2 
                                                                             && this.origine 
                                                                             && this.agency 
                                                                             && this.comment 
                                                                             && this.accountId 
                                                                             && this.erpNumber 
                                                                             && this.currencyIsoCode 
                                                                             && this.domain
                                                                              && this.subsidiary)
        {
        this.showModal();
        this.showWarningToast = false;
        this.showLoadingSpinner = true;
        }
    }
    saveLines(linesToSave, objectName, saveInvoicesLines) {
        this.isModalOpen = false;
        saveLines({ customerRequestId: this.customerRequestId, lines: JSON.stringify(linesToSave), objectName: objectName, domainIndex: this.domainIndex })
            .then((result) => {
                if (result === 'Success') {
                    if (saveInvoicesLines) {
                        this.saveLines(this.invoicesLinesToSave, 'InvoiceLine', false);
                    } else {
                        this.showSuccessToast = true;
                        this.successTxt = this.CustomerRequestFormSuccess;
                        setTimeout(() => {
                            window.location.href = "/lightning/r/CustomerRequest__c/" + this.customerRequestId + "/view";
                        }, 1000);
                    }
                } else {
                    this.showLoadingSpinner = false;
                    this.showWarningToast = true;
                    this.warningText = this.CustomerRequestFormSaveError;
                    setTimeout(() => {
                        this.showWarningToast = false; this.warningText = '';
                    }, 2500);
                    this.offset = 0;
                }
            })
            .catch((error) => {
                this.showLoadingSpinner = false;
                console.log(error);
                this.showErrorToast = true;
                setTimeout(() => {
                    this.showErrorToast = false;
                }, 3000);
            });
    }
    // InvoiceLines & SubscriptionLines
    handleParentCheckboxChange(event) {
        const parent = this.template.querySelector('[data-checkboxname="' + event.currentTarget.dataset.checkboxname + '"]');
        const items = this.template.querySelectorAll('[data-checkboxparentname="' + event.currentTarget.dataset.checkboxname + '"]');
        parent.classList.remove('childchecked');
        if (parent.checked == true) {
            items.forEach(function (item) {
                item.checked = true;
            })
        } else {
            items.forEach(function (item) {
                item.checked = false;
            })
        }
    }
    handleChildCheckboxChange(event) {
        const child = this.template.querySelector('[data-checkboxname="' + event.currentTarget.dataset.checkboxname + '"]');
        const parent = this.template.querySelector('[data-checkboxname="' + event.currentTarget.dataset.checkboxparentname + '"]');
        const items = this.template.querySelectorAll('[data-checkboxparentname="' + event.currentTarget.dataset.checkboxparentname + '"]');
        var i = 0;
        items.forEach(function (item) {
            if (item.checked == true) {
                i++;
            }
        })
        if (child.checked == true) {
            if (parent.getAttribute('data-totallines') == i) {
                parent.classList.remove('childchecked');
                parent.checked = true;
            } else {
                parent.classList.add('childchecked');
            }
        } else {
            parent.checked = false;
            if (i > 0) {
                parent.classList.add('childchecked');
            } else {
                parent.classList.remove('childchecked');
            }
        }
    }
    handleToggle(event) {
        const parent = this.template.querySelector('[data-togglename="' + event.currentTarget.dataset.togglename + '"]');
        const items = this.template.querySelectorAll('[data-parent="' + event.currentTarget.dataset.togglename + '"]');
        if (event.currentTarget.dataset.collapse == 'true') {
            parent.setAttribute('data-collapse', 'false');
            parent.style.transform = 'rotate(180deg)';
            items.forEach(function (item) {
                item.style.display = 'table-row';
            })
        } else {
            parent.setAttribute('data-collapse', 'true');
            parent.style.transform = 'rotate(0deg)';
            items.forEach(function (item) {
                item.style.display = 'none';
            })
        }
    }
    getSelectedIputs() {
        var items = this.template.querySelectorAll('.linecheckbox');
        var tempSelectedItemsNames = [];
        for (var i = 0; i < items.length; i++) {
            if (items[i].checked == true) {
                tempSelectedItemsNames.push(items[i].getAttribute('data-checkboxname'));
            }
        }
        this.selectedItemsNames = tempSelectedItemsNames
        items = this.template.querySelectorAll('.parentcheckbox');
        tempSelectedItemsNames = [];
        for (var i = 0; i < items.length; i++) {
            if (items[i].checked == true || items[i].classList.contains('childchecked')) {
                var parentdata = items[i].getAttribute('data-checkboxname') + "##" + items[i].getAttribute('data-totallines');
                if (items[i].classList.contains('childchecked')) {
                    parentdata += '&&childchecked';
                } else {
                    parentdata += '&&none';
                }
                tempSelectedItemsNames.push(parentdata);
            }
        }
        this.selectedParents = tempSelectedItemsNames;
    }
    setSelectedIputs() {
        var items = this.template.querySelectorAll('.linecheckbox');
        for (var i = 0; i < items.length; i++) {
            this.selectedItemsNames.forEach(function (selectedItem) {
                if (items[i].getAttribute('data-checkboxname') == selectedItem) {
                    items[i].checked = true;
                }
            })
        }
        items = this.template.querySelectorAll('.parentcheckbox');
        for (var i = 0; i < items.length; i++) {
            this.selectedParents.forEach(function (selectedItem) {
                if (String(items[i].getAttribute('data-checkboxname')) == String(selectedItem.split('##')[0]) && String(items[i].getAttribute('data-totallines')) == String(selectedItem.split('##').pop().split('&&')[0]) && String(selectedItem.split('&&')[1]) != 'childchecked') {
                    items[i].checked = true;
                    items[i].classList.remove('childchecked');
                } else if (items[i].getAttribute('data-checkboxname') == selectedItem.split('##')[0] || (items[i].getAttribute('data-checkboxname') == selectedItem.split('##')[0] && selectedItem.split('&&')[1] == 'childchecked')) {
                    items[i].checked = false;
                    items[i].classList.add('childchecked');
                }
            })
        }
    }
    parseJsonResult(result, isPagination) {
        var tempjson = JSON.parse(JSON.stringify(result).split('items').join('_children'));
        console.log("tempjson result : ", tempjson);
        if (tempjson[0].name == "ERROR") {
            this.showLoadingSpinner = false;
            this.showWarningToast = true;
            this.warningText = this.CustomerRequestFormWSError;
            setTimeout(() => {
                this.showWarningToast = false; this.warningText = '';
            }, 2500);
        } else {
            var i = 0;
            var oldJson = [];
            var tempinvoiceLines = [];
            var tempinvoiceNameSet = new Set();
            var tempMapinvoiceLines = new Map();
            if (isPagination == true) {
                oldJson = this.oldJson;
                tempinvoiceLines = this.invoiceLines;
                tempMapinvoiceLines = this.mapinvoiceLines;
            }
            tempjson.forEach(function (record) {
                oldJson.push(record);
            })
            oldJson.sort((a, b) => a.lineNumber.toLowerCase().localeCompare(b.lineNumber.toLowerCase()));
            oldJson.forEach(function (record) {
                if (record.amount == null && tempinvoiceNameSet.has(record.name) == false) {
                    tempinvoiceLines.push({ "totalLines": record.totalLines, 
                                            "name": record.name, 
                                            "totalAmount": record.totalAmount, 
                                            "lineNumber": record.lineNumber });
                    tempinvoiceNameSet.add(record.name);
                } else if (record.amount == null) {
                    for (i = 0; i < tempinvoiceLines.length; i++) {
                        if (tempinvoiceLines[i].name == record.name) {
                            tempinvoiceLines[i].totalLines = String(parseFloat(tempinvoiceLines[i].totalLines) + parseFloat(record.totalLines));
                            tempinvoiceLines[i].totalAmount = String(parseFloat(tempinvoiceLines[i].totalAmount) + parseFloat(record.totalAmount));
                        }
                    }
                }
                record._children.forEach(function (item) {
                    tempMapinvoiceLines.set(item.lineName, item);
                    tempinvoiceLines.push(item);
                })
            })
            this.mapinvoiceLines = tempMapinvoiceLines;
            this.invoiceLines = tempinvoiceLines;
            this.invoiceNameSet = tempinvoiceNameSet;
            this.oldJson = oldJson;
            this.showLoadingSpinner = false;
            setTimeout(() => {
                this.setSelectedIputs();
            }, 500);
        }
    }
    //TKN - "CANCELLATION TYPE - FILTER"
    
    filterSubscriptionByContractNum(contractNumber,result){
        console.log("TKN INVOICE LIST");
        console.log(JSON.stringify(this.invoiceNumSearchList));
        let filterResult = result.filter(lines => this.invoiceNumSearchList.includes(lines.contractNumber));

        console.log("filterResult: ",filterResult);

        return filterResult;
        
    }

    filterInvoiceNumber(contractNumber,result){
        console.log("TKN INVOICE LIST");
        console.log(JSON.stringify(this.invoiceNumSearchList));
        let filterResult = result.filter(lines => this.invoiceNumSearchList.includes(lines.lineNumber));

        console.log("filterResult: ",filterResult);

        return filterResult;
        
    }
    
    /*filterSubscriptionByContractNum(contractNumber,result){
        let filterResult = result.filter(lines => lines.contractNumber === contractNumber);
        return filterResult;
    }*/

    filterTiers(tierslivre,arrayOfElements){
    let filterResult =    arrayOfElements.map((result) => {
            return {...result, items: result.items.filter((items) => items.tierslivre === tierslivre)}
          })
              return filterResult;
    }

    filterBU(calculatedBu,arrayOfElements){

        let filterResult =    arrayOfElements.map((result) => {
                return {...result, items: result.items.filter((items) => items.calculatedBu === calculatedBu)}
              })

        console.log("filterresult bu",filterResult);
        return filterResult;
        }
    

    handleRefreshResults(isPagination) {
        var tempinvoiceLines = [];
        this.showLoadingSpinner = true;
        if (isPagination != true) {
            this.offset = 0;
            this.invoiceLines = [];
            this.selectedItemsNames = [];
            this.selectedParents = [];
            this.mapinvoiceLines = new Map();
            setTimeout(() => {
                this.setSelectedIputs();
            }, 500);
        } else {
            tempinvoiceLines = this.invoiceLines;
            this.invoiceLines = [];
        }
        if (this.showInvoicesLines && this.erpNumber && this.origine && this.domain) {
            if (this.warningAmounts || this.warningDates) {
                if (this.warningAmounts) {
                    this.compareAmounts();
                }
                else if (this.warningDates) {
                    this.compareDates();
                }
                this.showLoadingSpinner = false;
            } else {
                getInvoiceLinesData({ erpNumber: this.erpNumber, 
                                      domain: this.domain, 
                                      origin: this.origine, 
                                      businessUnitExternalId: this.businessUnitExternalId, 
                                      currencyIsoCode: this.currencyIsoCode, 
                                      contractNumber: this.contractNumber, 
                                      invoiceNumber: this.invoiceNumber, 
                                      //invoiceNumber: this.invoiceNumList,//invoiceNumList
                                      minAmount: this.amountMin, 
                                      maxAmount: this.amountMax, 
                                      minDate: this.dateMin ? this.dateMin.replaceAll("-", "") : '', 
                                      maxDate: this.dateMax ? this.dateMax.replaceAll("-", "") : '', 
                                      tierslivre: this.tierslivre, 
                                      offset: this.offset })
                    .then(result => {
                        if (result.length > 0) {
                            this.warningText = '';

                            if(this.invoiceNumber == '' && this.invoiceNumSearchList.length > 0){
                                result=this.filterInvoiceNumber(this.invoiceNumber,result);
                                console.log("invoice num",this.invoiceNumber);
                                console.log("invoice num leng", this.invoiceNumSearchList.length);
                                console.log("tkn res: ",result);
                                this.parseJsonResult(result, isPagination);
                                this.clearInvoiceNumberOnblur();
                            } else{
                                this.parseJsonResult(result, isPagination);

                            }
                            this.template.querySelector('[data-id="nextimg"]').style.display = "block";
                        } else {
                            this.showLoadingSpinner = false;
                            this.showWarningToast = true;
                            if (isPagination != true) {
                                this.warningText = this.CustomerRequestFormNoData;
                                setTimeout(() => {
                                    this.showWarningToast = false; this.warningText = '';
                                }, 2500);
                                this.offset = 0;
                            } else {
                                this.showWarningToast = true;
                                this.warningText = this.CustomerRequestFormNoMoreData;
                                setTimeout(() => {
                                    this.showWarningToast = false; this.warningText = '';
                                }, 2500);
                                this.invoiceLines = tempinvoiceLines;
                                setTimeout(() => {
                                    this.setSelectedIputs();
                                }, 500);
                            }
                            this.template.querySelector('[data-id="nextimg"]').style.display = "none";
                        }
                    })
                    .catch(error => {
                        console.log(error);
                        this.offset = 0;
                    })
            }
        } else if ((this.showSubscriptionInputs || this.showSubscriptionsWithInvoices) && this.erpNumber && this.origine && this.domain) {
            getSubscriptionLinesData({ erpNumber: this.erpNumber, 
                                       origin: this.origine, 
                                       domain: this.domain,
                                       currencyIsoCode: this.currencyIsoCode, 
                                       businessUnitExternalId: this.businessUnitExternalId, 
                                       offset: this.offset
                                    })
                .then(result => {
                    if (result.length > 0) {
                        this.warningText = '';

                        if(this.invoiceNumber == '' && this.invoiceNumSearchList.length > 0){
                            result=this.filterSubscriptionByContractNum(this.invoiceNumber,result);
                            this.parseJsonResult(result, isPagination);
                            this.clearInvoiceNumberOnblur();
                            
                        } else if(this.tierslivre){

                            result=this.filterTiers(this.tierslivre,result);

                        } else if(this.businessUnitExternalId){
                            result=this.filterBU(this.businessUnitExternalId,result);
                            this.parseJsonResult(result, isPagination);
                            this.clearInvoiceNumberOnblur();
                            
                        }
                        else{
                            console.log("tkn res: ",result);
                            this.parseJsonResult(result, isPagination);
                            this.clearInvoiceNumberOnblur();

                        }

                        this.template.querySelector('[data-id="nextimg"]').style.display = "block";
                    } else {
                        this.showLoadingSpinner = false;
                        this.showWarningToast = true;
                        if (isPagination != true) {
                            this.warningText = this.CustomerRequestFormNoData;
                            setTimeout(() => {
                                this.showWarningToast = false; this.warningText = '';
                            }, 2500);
                            this.offset = 0;
                        } else {
                            this.warningText = this.CustomerRequestFormNoMoreData;
                            setTimeout(() => {
                                this.showWarningToast = false; this.warningText = '';
                            }, 2500);
                            this.invoiceLines = tempinvoiceLines;
                            setTimeout(() => {
                                this.setSelectedIputs();
                            }, 500);
                        }
                        this.template.querySelector('[data-id="nextimg"]').style.display = "none";
                    }
                })
                .catch(error => {
                    console.log(error);
                    this.offset = 0;
                })
        } else {
            window.scrollTo(0, 0);
            this.showLoadingSpinner = false;
            this.showWarningToast = true;
            this.warningText = this.CustomerRequestFormRequired;
            if (!this.erpNumber) {
                this.erpNumberMissing = 'requiredfield missing';
            }
            if (!this.origine) {
                this.origineMissing = 'requiredfield missing';
            }
            if (!this.domain) {
                this.domainMissing = 'requiredfield missing';
            }
            setTimeout(() => {
                this.showWarningToast = false; this.warningText = '';
            }, 2500);
            this.offset = 0;
        }
    }
    next() {
        this.getSelectedIputs();
        this.offset += this.offsetCs;
        this.handleRefreshResults(true);
    }

    changeToggle(){
    this.checked = !this.checked;
    console.log("TKN-TOGGLE",this.checked);
    if(this.checked == false){//manual
        this.showInvoiceInputs = false;
        this.showSearchedResult =false;
        this.showBusinessUnit=true;
        this.techManual=true;
        this.nextButton=false;
        this.nextButton2=true;
    }else{//auto
        this.showInvoiceInputs = true;
        this.showSearchedResult = true;
        this.nextButton=true;
        this.nextButton2=false;
        this.showBusinessUnit=false;
    }
}
}