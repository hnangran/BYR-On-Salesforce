import { LightningElement, api } from 'lwc';

export default class Certsstep extends LightningElement {
    @api resumeId;

    @api validate() {
        return true;
    }

    @api submit() {
        const event = new CustomEvent('success', { detail: { id: this.resumeId } });
        this.dispatchEvent(event);
    }
}
