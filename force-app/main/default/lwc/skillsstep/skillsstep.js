import { LightningElement, api } from 'lwc';

export default class Skillsstep extends LightningElement {
    @api resumeId;

    @api validate() {
        return true;
    }

    @api submit() {
        const event = new CustomEvent('success', { detail: { id: this.resumeId } });
        this.dispatchEvent(event);
    }
}
