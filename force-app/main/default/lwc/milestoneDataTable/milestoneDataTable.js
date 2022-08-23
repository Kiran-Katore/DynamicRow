import { api, LightningElement, track, wire } from 'lwc';
import getMilestones from '@salesforce/apex/Dynamic_milestoneCreator.getData';

export default class MilestoneDataTable extends LightningElement {

    @api recordId;
    @track dataTableData = null;
    @track dataTableFlag = false;

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
}