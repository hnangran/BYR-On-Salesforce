import { createElement } from 'lwc';
import CreateResume from 'c/createresume';

function appendComponent() {
    const element = createElement('c-createresume', {
        is: CreateResume
    });
    document.body.appendChild(element);
    return element;
}

function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-createresume', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders the basic step by default', async () => {
        const element = appendComponent();
        await flushPromises();

        expect(element.shadowRoot.querySelector('c-basicinfostep')).toBeTruthy();
        expect(element.shadowRoot.querySelector('c-educationstep')).toBeFalsy();
    });

    it('switches steps when the path component fires a change event', async () => {
        const element = appendComponent();
        await flushPromises();
        const indicator = element.shadowRoot.querySelector('lightning-progress-indicator');

        indicator.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'skills' }
        }));

        await flushPromises();

        expect(element.shadowRoot.querySelector('c-skillsstep')).toBeTruthy();
        expect(element.shadowRoot.querySelector('c-basicinfostep')).toBeFalsy();
    });

    it('validates and submits the active child before moving to the next step', async () => {
        const element = appendComponent();
        await flushPromises();
        const child = element.shadowRoot.querySelector('c-basicinfostep');
        child.validate = jest.fn().mockReturnValue(true);
        child.submit = jest.fn();

        const nextButton = element.shadowRoot.querySelector('lightning-button[title="Next"]');
        nextButton.dispatchEvent(new CustomEvent('click'));

        expect(child.validate).toHaveBeenCalledTimes(1);
        expect(child.submit).toHaveBeenCalledTimes(1);

        child.dispatchEvent(new CustomEvent('success', {
            detail: { id: '001' },
            bubbles: true,
            composed: true
        }));

        await flushPromises();

        expect(element.shadowRoot.querySelector('c-educationstep')).toBeTruthy();
    });

    it('does not submit when validation fails', async () => {
        const element = appendComponent();
        await flushPromises();
        const child = element.shadowRoot.querySelector('c-basicinfostep');
        child.validate = jest.fn().mockReturnValue(false);
        child.submit = jest.fn();

        const nextButton = element.shadowRoot.querySelector('lightning-button[title="Next"]');
        nextButton.dispatchEvent(new CustomEvent('click'));

        expect(child.validate).toHaveBeenCalledTimes(1);
        expect(child.submit).not.toHaveBeenCalled();
        expect(element.shadowRoot.querySelector('c-educationstep')).toBeFalsy();
    });

    it('moves back one step when the Back button is clicked', async () => {
        const element = appendComponent();
        await flushPromises();
        const child = element.shadowRoot.querySelector('c-basicinfostep');
        child.validate = jest.fn().mockReturnValue(true);
        child.submit = jest.fn();

        const nextButton = element.shadowRoot.querySelector('lightning-button[title="Next"]');
        nextButton.dispatchEvent(new CustomEvent('click'));
        child.dispatchEvent(new CustomEvent('success', {
            detail: { id: '001' },
            bubbles: true,
            composed: true
        }));

        await flushPromises();
        expect(element.shadowRoot.querySelector('c-educationstep')).toBeTruthy();

        const backButton = element.shadowRoot.querySelector('lightning-button[title="Back"]');
        backButton.dispatchEvent(new CustomEvent('click'));

        await flushPromises();
        expect(element.shadowRoot.querySelector('c-basicinfostep')).toBeTruthy();
    });
});
