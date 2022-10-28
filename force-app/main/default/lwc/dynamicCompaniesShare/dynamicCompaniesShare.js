import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import NO_OF_MILESTONE from '@salesforce/schema/VLSF_Opportunity__c.Payment_Milestone__c';
import COMPANIES_INVOLVED from '@salesforce/schema/VLSF_Opportunity__c.Companies_Share_To_Create__c';
import AMOUNT_ROW from '@salesforce/schema/VLSF_Opportunity__c.Amount_ROW__c';
import createCompanies from '@salesforce/apex/Companies_Share_ROW.createCompanies'


export default class DynamicCompaniesShare extends LightningElement {

    @api recordId;
    @api isLoading = false;
    @track no_of_milestones = 0;
    record_Amount = 0;
    total_percentage = 0;
    @track CompaniesShareFlag = true;
    @track milestoneRecList = [];


    value = 'Vyom India';

    
    get options() {
        return [
            { label: 'VyomSG', value: 'VyomSG' },
            { label: 'ITSM', value: 'ITSM' },
            { label: 'A&A', value: 'A&A' },
            { label: 'SFRF', value: 'SFRF' },
            { label: 'IT', value: 'IT' },
            { label: 'ITIL', value: 'ITIL' },
            { label: 'Cogniwize', value: 'Cogniwize' },
            { label: 'DX Sherpa', value: 'DX Sherpa' },
            { label: 'AE', value: 'AE' },
            { label: 'Omnepresent', value: 'Omnepresent' },
            { label: 'DBA', value: 'DBA' },
            { label: 'ServiceRize', value: 'ServiceRize' },
            { label: 'Accscient Digital', value: 'Accscient Digital' },
            { label: 'A2U', value: 'A2U' },
            { label: 'Appridat', value: 'Appridat' },
            { label: 'BITB', value: 'BITB' },
            { label: 'Ellicium', value: 'Ellicium' },
            { label: 'Emergys', value: 'Emergys' },
            { label: 'Intra System', value: 'Intra System' },
            { label: 'MCS', value: 'MCS' },
            { label: 'Norwin', value: 'Norwin' },
            { label: 'Ovaledge', value: 'Ovaledge' },
            { label: 'PDS', value: 'PDS' },
            { label: 'Premier IT', value: 'Premier IT' },
        ];
    }


    @wire(getRecord, { recordId: '$recordId', fields: [COMPANIES_INVOLVED, AMOUNT_ROW] })
    fetchRecord({ data, error }) {
        if (data) {
            this.no_of_milestones = 0;
            this.milestoneRecList = [];
            console.log(data.fields.Companies_Share_To_Create__c.value);
            this.no_of_milestones = data.fields.Companies_Share_To_Create__c.value;
            this.record_Amount = data.fields.Amount_ROW__c.value;
            //this.po_id = data.fields.PO_ROW_ID__c.value;
            if(this.no_of_milestones < 0){
                this.no_of_milestones = 0;
            }
            console.log('involved =>'+this.no_of_milestones);
            for (let i = 0; i < this.no_of_milestones; i++) {
                this.milestoneRecList.push({
                    Name: null,
                    Percentage: null,
                    Amount: null
                });
            }
            if (this.no_of_milestones == 0) {
                this.CompaniesShareFlag = false;
                updateRecord({ fields: { Id: this.recordId } });
            }
            
            //console.log('data==>'+JSON.stringify(data));
        } else if (error) {
            console.log('error ==>' + error);
        }
    }

    showData(){
        console.log(this.milestoneRecList);
    }

    changeHandler(event) {
        console.log(event.target.name);
        if (event.target.name == 'Name') {
            console.log('Name =' + event.target.value);
            console.log('access Key =' + event.target.accessKey);
            this.milestoneRecList[event.target.accessKey].Name = event.target.value;
        }
        if (event.target.name == 'Percentage') {
            console.log('Percentage =' + event.target.value);
            this.milestoneRecList[event.target.accessKey].Percentage = event.target.value;
            if (this.total_percentage >= 100) {
                console.log(this.total_percentage);
            } else {
                //this.milestoneRecList[event.target.accessKey].Percentage = event.target.value;
                //this.milestoneRecList[event.target.accessKey].Amount = parseInt(event.target.value);
                this.milestoneRecList[event.target.accessKey].Amount = this.record_Amount * parseInt(event.target.value) / 100;
                console.log(this.milestoneRecList[event.target.accessKey].Amount);
            }

        }
        if (event.target.name == 'DueDate') {
            console.log('DueDate =' + event.target.value);
            this.milestoneRecList[event.target.accessKey].DueDate = event.target.value;
        }
        if (event.target.name == 'Amount') {
            console.log('Amount =' + event.target.value);
            this.milestoneRecList[event.target.accessKey].Amount = event.target.value;
        }
        if (event.target.accessKey == (this.milestoneRecList.length - 1) && event.target.name != 'Percentage' && this.milestoneRecList[event.target.accessKey - 1] != '') {
            this.total_percentage = 0;
            let temp_perc = 0;
            for (let i = 0; i < this.milestoneRecList.length; i++) {
                this.total_percentage += parseInt(this.milestoneRecList[i].Percentage);
                console.log('total Percentage ==>' + this.total_percentage);
                if (i != this.milestoneRecList.length - 1) {
                    temp_perc += parseInt(this.milestoneRecList[i].Percentage);
                    console.log('temp =>' + temp_perc);
                }
            }
            if (this.total_percentage < 100) {
                //this.milestoneRecList[this.milestoneRecList.length - 1].Percentage = 100 - temp_perc;
                //this.milestoneRecList[event.target.accessKey].Amount = this.record_Amount * parseInt(this.milestoneRecList[this.milestoneRecList.length - 1].Percentage) / 100;
            } else if (this.total_percentage > 100) {
                alert('Percentage is Higher');
            }
        }
    }
    createCompaniesShare() {
        this.total_percentage = 0;

        for (let i = 0; i < this.milestoneRecList.length; i++) {
            if (this.milestoneRecList[i].Percentage != '') {
                this.total_percentage += parseInt(this.milestoneRecList[i].Percentage);
                console.log('total Percentage ==>' + this.total_percentage);
            }
        }
        if (this.total_percentage > 100) {
            alert('Percentage Exceeded');
        } else {
            if (this.total_percentage < 100) {
                let text = "Percentage Should be 100%";
                alert(text);
            } else {
                this.isLoading = !this.isLoading;
                createCompanies({ cmps: this.milestoneRecList, recordId: this.recordId})
                    .then((result) => {
                        this.dataTableData = result;
                        this.isLoading = !this.isLoading;
                        console.log('result Call ==>' + JSON.stringify(result));
                        console.log('list size:' + result.length);
                        window.location.reload();
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'SUCCESS!',
                            message: 'Successfully inserted Milestones',
                            variant: 'success'
                        }));
                    }).catch((err) => {
                        console.log('Error' + JSON.stringify(err));
                        this.isLoading = !this.isLoading;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'ERROR!',
                            message: 'Error while inserting Milestones: Data Error!',
                            variant: 'error'
                        }));
                    });
            }

            console.log('Parameters milestoneList ==>' + JSON.stringify(this.milestoneRecList));
            console.log('Parameters recordId ==>' + this.recordId);
            console.log('Parameters po_id ==>' + this.po_id);
        }
    }
    cancelMilestone(event) {
        this.milestoneRecList.pop(event.target.accessKey);
        console.log('Removed');
    }
}