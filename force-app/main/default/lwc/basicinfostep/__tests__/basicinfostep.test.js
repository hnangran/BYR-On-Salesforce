import { createElement } from 'lwc';
import BasicInfoStep from 'c/basicinfostep';

describe('c-basicinfostep', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('calls reportValidity on all inputs and returns true when they are valid', () => {
        const element = createElement('c-basicinfostep', {
            is: BasicInfoStep
        });
        document.body.appendChild(element);

        const inputs = element.shadowRoot.querySelectorAll('lightning-input-field');
        inputs.forEach((input) => {
            input.reportValidity = jest.fn().mockReturnValue(true);
        });

        expect(element.validate()).toBe(true);
        inputs.forEach((input) => {
            expect(input.reportValidity).toHaveBeenCalledTimes(1);
        });
    });

    it('returns false when any input reports invalid', () => {
        const element = createElement('c-basicinfostep', {
            is: BasicInfoStep
        });
        document.body.appendChild(element);

        const [first, ...rest] = element.shadowRoot.querySelectorAll('lightning-input-field');
        first.reportValidity = jest.fn().mockReturnValue(false);
        rest.forEach((input) => {
            input.reportValidity = jest.fn().mockReturnValue(true);
        });

        expect(element.validate()).toBe(false);
        expect(first.reportValidity).toHaveBeenCalledTimes(1);
        rest.forEach((input) => {
            expect(input.reportValidity).not.toHaveBeenCalled();
        });
    });

    it('submits the underlying record edit form', () => {
        const element = createElement('c-basicinfostep', {
            is: BasicInfoStep
        });
        document.body.appendChild(element);

        const form = element.shadowRoot.querySelector('lightning-record-edit-form');
        form.submit = jest.fn();

        element.submit();

        expect(form.submit).toHaveBeenCalledTimes(1);
    });
});
