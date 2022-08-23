import { api, LightningElement, track, wire } from 'lwc';
import milestoneCreate from '@salesforce/apex/Dynamic_milestoneCreator.createMilestone';
import getMilestones from '@salesforce/apex/Dynamic_milestoneCreator.getData';
import NO_OF_MILESTONE from '@salesforce/schema/VLSF_Opportunity__c.Payment_Milestone__c';
import AMOUNT_ROW from '@salesforce/schema/VLSF_Opportunity__c.Amount_ROW__c';
import MILESTONE_TO_CREATE from '@salesforce/schema/VLSF_Opportunity__c.Milestone_to_Create__c';
import PO_ID from '@salesforce/schema/VLSF_Opportunity__c.PO_ROW_ID__c';
import REMAIN_AMOUNT from '@salesforce/schema/VLSF_Opportunity__c.Milestone_Remaining_Amount__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

export default class DynamicRowOpportunity extends LightningElement {
    @api recordId;
    @api isLoading = false;
    @track no_of_milestones = 0;
    record_Amount = 0;
    total_percentage = 0;
    po_id = null;
    @track milestoneCreatorFlag = true;
    @track dataTableFlag = false;
    @track dataTableData = null;
    @track milestoneRecList = [];


    @wire(getMilestones, { recId: '$recordId' })
    getMilestone({ data, error }) {
        if (data) {
            let dataList = [];
            data.forEach((record) => {
                let dt = Object.assign({}, record);
                dt.URL = '/' + dt.Id;
                dataList.push(dt);
            });
            this.dataTableData = dataList;
            if (this.dataTableData.length > 0) {
                this.dataTableFlag = true;

            }
            console.log('data URL ==> ' + JSON.stringify(this.dataTableData));
            console.log('data ==> ' + JSON.stringify(data));
        } else if (error) {
            console.log('error ==> ' + error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NO_OF_MILESTONE, AMOUNT_ROW, MILESTONE_TO_CREATE, PO_ID, REMAIN_AMOUNT] })
    fetchRecord({ data, error }) {
        if (data) {
            this.no_of_milestones = 0;
            this.milestoneRecList = [];
            console.log(data.fields.Payment_Milestone__c.value);
            this.no_of_milestones = data.fields.Milestone_to_Create__c.value;
            this.record_Amount = data.fields.Milestone_Remaining_Amount__c.value;
            this.po_id = data.fields.PO_ROW_ID__c.value;
            for (let i = 0; i < this.no_of_milestones; i++) {
                this.milestoneRecList.push({
                    Name: null,
                    Percentage: null,
                    Amount: null,
                    DueDate: null
                });
            }
            if (this.no_of_milestones == 0) {
                this.milestoneCreatorFlag = false;
                updateRecord({ fields: { Id: this.recordId } });
            }
            
            //console.log('data==>'+JSON.stringify(data));
        } else if (error) {
            console.log('error ==>' + error);
        }
    }

    // renderedCallback(){
    //     for(let i=0; i < this.no_of_milestones; i++){
    //         this.milestoneRecList.push({
    //             Name:'',
    //             Percentage:'',
    //             Amount:'',
    //             DueDate:''
    //         });
    //     }
    // }
    saveMilestones() {
        console.log('Called');
    }
    cancelMilestone(event) {
        this.milestoneRecList.pop(event.target.accessKey);
        console.log('Removed');
    }
    changeHandler(event) {
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
                this.milestoneRecList[this.milestoneRecList.length - 1].Percentage = 100 - temp_perc;
                this.milestoneRecList[event.target.accessKey].Amount = this.record_Amount * parseInt(this.milestoneRecList[this.milestoneRecList.length - 1].Percentage) / 100;
            } else if (this.total_percentage > 100) {
                alert('Percentage is Higher');
            }
        }
    }
    createMilestone() {
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
                //confirm("Percentage is Not 100%. Please confirm to Proceed!");
                let text = "Percentage is Not 100%. Please confirm to Proceed!";
                if (confirm(text) == true) {
                    this.isLoading = !this.isLoading;
                    milestoneCreate({ milestoneList: this.milestoneRecList, recordId: this.recordId, poId: this.po_id })
                        .then((result) => {
                            this.dataTableData = result;
                            this.dataTableFlag = true;
                            this.isLoading = !this.isLoading;
                            console.log('result Call ==>' + JSON.stringify(result));
                            console.log('list size:' + result.length);
                            //updateRecord({ fields: { Id: this.recordId } });
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
                } else {
                    console.log('Operation Cancelled!');
                }
            } else {
                this.isLoading = !this.isLoading;
                milestoneCreate({ milestoneList: this.milestoneRecList, recordId: this.recordId, poId: this.po_id })
                    .then((result) => {
                        this.dataTableData = result;
                        this.dataTableFlag = true;
                        this.isLoading = !this.isLoading;
                        console.log('result Call ==>' + JSON.stringify(result));
                        console.log('list size:' + result.length);
                        //updateRecord({ fields: { Id: this.recordId } });
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
}