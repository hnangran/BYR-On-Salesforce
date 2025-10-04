const fs = require('fs');
const path = require('path');

function loadController() {
    const filePath = path.resolve(__dirname, '../CreateEditResumeOverrideAuraController.js');
    const source = fs.readFileSync(filePath, 'utf8');
    // The controller file exports an object literal "({ ... })"; evaluating it yields the controller instance.
    // eslint-disable-next-line no-new-func
    return new Function(`return ${source}`)();
}

const controller = loadController();

describe('CreateEditResumeOverrideAuraController', () => {
    function buildComponent(pageReference) {
        const navService = { navigate: jest.fn() };
        return {
            get: jest.fn((key) => (key === 'v.pageReference' ? pageReference : undefined)),
            find: jest.fn(() => navService),
            navService
        };
    }

    it('navigates to the Create Resume tab with edit context when a recordId is present', () => {
        const pageReference = {
            state: {
                recordId: 'a01',
                recordTypeId: '012',
                retURL: '/return',
                inContextOfRef: 'encodedContext'
            }
        };
        const component = buildComponent(pageReference);

        controller.doInit(component);

        expect(component.find).toHaveBeenCalledWith('nav');
        expect(component.navService.navigate).toHaveBeenCalledWith({
            type: 'standard__navItemPage',
            attributes: { apiName: 'Create_Resume' },
            state: {
                c__mode: 'edit',
                c__recordId: 'a01',
                c__recordTypeId: '012',
                c__retURL: '/return',
                c__inContextOfRef: 'encodedContext'
            }
        }, true);
    });

    it('falls back to new mode when no recordId value exists in the state', () => {
        const pageReference = {
            state: {
                id: null,
                recordTypeId: '012'
            }
        };
        const component = buildComponent(pageReference);

        controller.doInit(component);

        expect(component.navService.navigate).toHaveBeenCalledWith(expect.objectContaining({
            state: expect.objectContaining({
                c__mode: 'new',
                c__recordId: null,
                c__recordTypeId: '012'
            })
        }), true);
    });
});
