VERSION		:= 9999.0.6+tormath1-linode
IMAGE		:= flatcar_production_akamai_image-${VERSION}.img.gz
IMAGE_URL	:= https://linode-flatcar-images.us-ord-1.linodeobjects.com/${IMAGE}
IMAGE_LABEL	:= flatcar-linux
REGION		:= us-ord
INSTANCE_TYPE	:= g6-nanode-1
INSTANCE_LABEL	:= flatcar-demo

${IMAGE}:
	curl -Lo $@ ${IMAGE_URL}

.PHONY: upload-image
upload-image: ${IMAGE}
	linode image-upload --region "${REGION}" --label "${IMAGE_LABEL}" --no-defaults "${IMAGE}"

ignition.json: butane.yaml
	butane < $< > $@

.PHONY: instance
instance: id_ed25519.pub ignition.json
	linode linodes create \
		--region "${REGION}" \
		--booted false \
		--type "${INSTANCE_TYPE}" \
		--metadata.user_data "$(shell base64 -w0 ignition.json)" \
		--label "${INSTANCE_LABEL}" \
		--no-defaults

.PHONY: instance-disk
instance-disk:
	linode linodes disk-create \
		--size "$(shell ${MAKE} --quiet max-disk-size)" \
		--label flatcar-boot \
		--image "$(shell ${MAKE} --quiet image-id)" \
		--root_pass "jaegerzwei12914" \
		--no-defaults \
		"$(shell ${MAKE} --quiet instance-id)"

.PHONY: instance-config
instance-config:
	linode linodes config-create \
		--kernel linode/direct-disk \
		--helpers.updatedb_disabled true \
		--helpers.distro false \
		--helpers.modules_dep false \
		--helpers.network false \
		--helpers.devtmpfs_automount false \
		--label default \
		--devices.sda.disk_id "$(shell ${MAKE} --quiet disk-id)" \
		--root_device sda \
		"$(shell ${MAKE} --quiet instance-id)"

.PHONY: image-id
image-id: 
	@linode images list --is_public false --label "${IMAGE_LABEL}" --json | jq -r '.[0].id'

.PHONY: instance-id
instance-id:
	@linode linodes list --label "${INSTANCE_LABEL}" --json | jq -r '.[0].id'

.PHONY: max-disk-size
max-disk-size:
	@linode linodes type-view "${INSTANCE_TYPE}" --json | jq -r '.[0].disk'

.PHONY: disk-id
disk-id:
	@linode linodes disks-list "$(shell ${MAKE} --quiet instance-id)" --json | jq -r '.[0].id'

.PHONY: clean
clean:
	-rm ${IMAGE}

.PHONY: destroy
destroy:
	-linode linodes rm "$(shell ${MAKE} --quiet instance-id)"
