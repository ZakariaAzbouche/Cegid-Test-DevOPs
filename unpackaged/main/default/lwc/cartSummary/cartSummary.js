import { api, LightningElement, wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/B2BCartControllerSample.getCartSummary';

import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtils';

import messageChannel from '@salesforce/messageChannel/b2bMessageChannel__c';
import {subscribe, MessageContext} from 'lightning/messageService';

// Get the base path for navigating to non-named pages
import communityBasePath from '@salesforce/community/basePath';
import { NavigationMixin } from "lightning/navigation";


const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class CartSummary extends LightningElement {
    /*create/returns a MessageContext object which contains information*/
    @wire(MessageContext)
    messageContext;
    /*initialise subscription*/
    subscription = null;
    participantIds = [];

    numberOflineVerify;
    remaingcount;
    substractLine;
    checkoutButton = true;
    currentcommunityBasePath;


    /**
     * An event fired when the cart items change.
     * This event is a short term resolution to update any sibling component that may want to update their state based
     * on updates in the cart items.
     *
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     *
     * @event CartContents#cartitemsupdated
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * The pricing information for the cart summary's total.
     *
     * @typedef {Object} Prices
     *
     * @property {String} [originalPrice]
     *  The  list price aka "strikethrough" price (i.e. MSRP) of the cart.
     *  If the value is null, undefined, or empty, the list price will not be displayed.
     *
     * @property {String} finalPrice
     *   The final price of the cart.
     */

    /**
     * The recordId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    recordId;

    /**
     * The effectiveAccountId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     * We want to start listening for the 'cartitemsupdated'
     *
     * NOTE:
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     */
    connectedCallback() {
        registerListener(
            CART_ITEMS_UPDATED_EVT,
            this.getUpdatedCartSummary,
            this
        );
        // Initialize 'cartsummary' as soon as the component is inserted in the DOM  by
        // calling getCartSummary imperatively.
        this.getUpdatedCartSummary();
        this.handleSubscribe();
        this.currentcommunityBasePath = communityBasePath;
        
        //
    }

    //handle all subscribe events
    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, messageChannel, (message) => {
            
            if(message.participantidToSend != null && message.participantidToSend != undefined){
                //console.log(' this.participantIds :  ' ,  this.participantIds);
                this.participantIds.push( message.participantidToSend);
            }

            if(message.remaningCount != null || message.remaningCount != undefined){
                this.remaingcount = message.remaningCount;
                //console.log(' remaningCount :  ' ,  message.remaningCount);
            }

            if(message.CountToSubstract != null || message.CountToSubstract != undefined){
                this.substractLine =  message.CountToSubstract;
                //console.log(' CountToSubstract :  ' ,  message.CountToSubstract);
            }

            if( this.remaingcount != null && this.substractLine != null){
                this.numberOflineVerify = this.remaingcount-this.substractLine;
                //console.log(' this.numberOflineVerify : ' , this.numberOflineVerify);
            }
            //console.log('this.numberOflineVerify checkout' , this.numberOflineVerify);
            //console.log('this.participantIds.length checkout' , this.participantIds.length);
            if(this.numberOflineVerify === this.participantIds.length && this.participantIds.length > 0){
                this.template.querySelector('[data-id="buttonstart"]').className=' slds-button slds-button_brand slds-button_full-width slds-align_absolute-center slds-m-top_medium slds-m-bottom_medium slds-p-top_small slds-p-bottom_small custombtn ';
                this.checkoutButton = false;
            }else if(this.numberOflineVerify === this.participantIds.length && this.participantIds.length == 0){
               // console.log('button');
                this.template.querySelector('[data-id="buttonstart"]').className=' slds-button slds-button_brand slds-button_full-width slds-align_absolute-center slds-m-top_medium slds-m-bottom_medium slds-p-top_small slds-p-bottom_small custombtn ';
                this.checkoutButton = false;
            }else{
                this.template.querySelector('[data-id="buttonstart"]').className=' slds-button slds-button_brand slds-button_full-width slds-align_absolute-center slds-m-top_medium slds-m-bottom_medium slds-p-top_small slds-p-bottom_small disabled ';
                this.checkoutButton = true;
            }
        });
       
    }

    /**
     * This lifecycle hook fires when this component is removed from the DOM.
     */
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    /**
     * The labels used in the template.
     * To support localization, these should be stored as custom labels.
     *
     * To import labels in an LWC use the @salesforce/label scoped module.
     * https://developer.salesforce.com/docs/component-library/documentation/en/lwc/create_labels
     *
     * @type {Object}
     * @private
     * @readonly
     */
    get labels() {
        return {
            cartSummaryHeader: 'Total du Panier',
            total: 'Total'
        };
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    /**
     * The pricing information to be displayed in the summary
     * @type {Prices}
     */
    get prices() {
        return {
            originalPrice: this.cartSummary && this.cartSummary.totalListPrice,
            finalPrice: this.cartSummary && this.cartSummary.totalProductAmount
        };
    }

    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {String}
     */
    get currencyCode() {
        return (this.cartSummary && this.cartSummary.currencyIsoCode) || 'USD';
    }

    /**
     * Representation for Cart Summary
     *
     * @type {object}
     * @readonly
     * @private
     */
    cartSummary;

    /**
     * Get cart summary from the server via imperative apex call
     */
    getUpdatedCartSummary() {
        getCartSummary({
            communityId: communityId,
            activeCartOrId: this.recordId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((cartSummary) => {
                this.cartSummary = cartSummary;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }

    /**
     * Should the original price be shown
     * @returns {boolean} true, if we want to show the original (strikethrough) price
     * @private
     */
    get showOriginal() {
        return displayOriginalPrice(
            true,
            true,
            this.prices.finalPrice,
            this.prices.originalPrice
        );
    }

    /**
     * Gets the dynamically generated aria label for the original price element
     * @returns {string} aria label for original price
     * @private
     */
    get ariaLabelForOriginalPrice() {
        return getLabelForOriginalPrice(
            this.currencyCode,
            this.prices.originalPrice
        );
    }

    startFlow(){
        window.location.assign(this.currentcommunityBasePath+'/checkout/'+this.recordId);
    }



}