import { createElement } from 'lwc';
import SelectResume from 'c/selectresume';
import getProfiles from '@salesforce/apex/BYROS_ResumeService.getProfiles';
import getResumes from '@salesforce/apex/BYROS_ResumeService.getResumes';
import { createApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

jest.mock('@salesforce/apex/BYROS_ResumeService.getResumes', () => ({
    default: jest.fn()
}), { virtual: true });

createApexTestWireAdapter(getProfiles);

function appendComponent() {
    const element = createElement('c-selectresume', {
        is: SelectResume
    });
    document.body.appendChild(element);
    return element;
}

function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-selectresume', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('fetches resumes and raises profile/resume events when the profile changes', async () => {
        const element = appendComponent();
        const resumeListener = jest.fn();
        const profileListener = jest.fn();
        element.addEventListener('resumechange', resumeListener);
        element.addEventListener('profilechange', profileListener);

        const resumes = [{ label: 'Resume 1', value: 'r1' }];
        getResumes.mockResolvedValue(resumes);

        const profileCombobox = element.shadowRoot.querySelectorAll('lightning-combobox')[0];
        profileCombobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'p1' }
        }));

        await flushPromises();

        expect(getResumes).toHaveBeenCalledWith({ profileId: 'p1' });
        expect(profileListener).toHaveBeenCalledWith(expect.objectContaining({ detail: { profileId: 'p1' } }));
        expect(resumeListener).toHaveBeenCalledWith(expect.objectContaining({ detail: { resumeId: null } }));
    });

    it('enables actions and emits resumechange when a resume is chosen', () => {
        const element = appendComponent();
        const resumeListener = jest.fn();
        element.addEventListener('resumechange', resumeListener);

        const [ , resumeCombobox ] = element.shadowRoot.querySelectorAll('lightning-combobox');
        resumeCombobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'r1' }
        }));

        expect(resumeListener).toHaveBeenCalledWith(expect.objectContaining({ detail: { resumeId: 'r1' } }));
    });

    it('fires displayresume when the load button is clicked', () => {
        const element = appendComponent();
        const [ , resumeCombobox ] = element.shadowRoot.querySelectorAll('lightning-combobox');
        resumeCombobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'r2' }
        }));
        const listener = jest.fn();
        element.addEventListener('displayresume', listener);

        const [loadButton] = element.shadowRoot.querySelectorAll('lightning-button');
        loadButton.dispatchEvent(new CustomEvent('click'));

        expect(listener).toHaveBeenCalledWith(expect.objectContaining({ detail: { resumeId: 'r2' } }));
    });

    it('opens a new tab with the resume PDF when the download button is clicked', () => {
        const element = appendComponent();
        const [ , resumeCombobox ] = element.shadowRoot.querySelectorAll('lightning-combobox');
        resumeCombobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'r3' }
        }));
        window.open = jest.fn();

        const [, downloadButton] = element.shadowRoot.querySelectorAll('lightning-button');
        downloadButton.dispatchEvent(new CustomEvent('click'));

        expect(window.open).toHaveBeenCalledWith('/apex/BYROS_ResumeAsPDF?id=r3', '_blank');
    });
});
