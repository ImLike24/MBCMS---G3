<%--
  Reusable Confirmation Modal Component
  Usage: <%@ include file="confirm-modal.jsp" %>
  Then call: showConfirmModal({ title, message, confirmText, cancelText }) -> Promise<boolean>
--%>
<div class="confirm-modal-overlay" id="confirmModalOverlay">
    <div class="confirm-modal">
        <div class="confirm-modal-icon">
            <i id="confirmModalIcon" class="fas fa-exclamation-triangle"></i>
        </div>
        <h3 class="confirm-modal-title" id="confirmModalTitle">Confirm Action</h3>
        <p class="confirm-modal-message" id="confirmModalMessage">Are you sure you want to proceed?</p>
        <div class="confirm-modal-actions">
            <button class="confirm-modal-btn cancel" id="confirmModalCancelBtn">
                <i class="fas fa-times"></i>
                <span id="confirmModalCancelText">Cancel</span>
            </button>
            <button class="confirm-modal-btn confirm" id="confirmModalConfirmBtn">
                <i class="fas fa-check"></i>
                <span id="confirmModalConfirmText">Confirm</span>
            </button>
        </div>
    </div>
</div>

<script>
    (function () {
        let _resolve = null;

        const overlay  = document.getElementById('confirmModalOverlay');
        const cancelBtn  = document.getElementById('confirmModalCancelBtn');
        const confirmBtn = document.getElementById('confirmModalConfirmBtn');

        function closeModal(result) {
            overlay.classList.remove('active');
            if (_resolve) {
                _resolve(result);
                _resolve = null;
            }
        }

        cancelBtn.addEventListener('click',  () => closeModal(false));
        confirmBtn.addEventListener('click', () => closeModal(true));

        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) closeModal(false);
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && overlay.classList.contains('active')) {
                closeModal(false);
            }
        });

        /**
         * Show a custom confirmation modal.
         * @param {object} options
         * @param {string} [options.title='Confirm Action']
         * @param {string} [options.message='Are you sure you want to proceed?']
         * @param {string} [options.confirmText='Confirm']
         * @param {string} [options.cancelText='Cancel']
         * @param {string} [options.icon='fas fa-exclamation-triangle']
         * @returns {Promise<boolean>}
         */
        window.showConfirmModal = function ({
            title       = 'Confirm Action',
            message     = 'Are you sure you want to proceed?',
            confirmText = 'Confirm',
            cancelText  = 'Cancel',
            icon        = 'fas fa-exclamation-triangle'
        } = {}) {
            document.getElementById('confirmModalTitle').textContent       = title;
            document.getElementById('confirmModalMessage').textContent     = message;
            document.getElementById('confirmModalConfirmText').textContent = confirmText;
            document.getElementById('confirmModalCancelText').textContent  = cancelText;
            document.getElementById('confirmModalIcon').className          = icon;

            return new Promise((resolve) => {
                _resolve = resolve;
                overlay.classList.add('active');
            });
        };
    })();
</script>
