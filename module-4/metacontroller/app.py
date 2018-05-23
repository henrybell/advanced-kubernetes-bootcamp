from flask import Flask, jsonify, request
import copy
import os
import re

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def sync():
    if request.method == 'GET': return "OK"

    desired_status = {"passed": [], "failed": []}
    req = request.get_json()
    desired_deploys = req["children"].get("Deployment.apps/v1")

    ### Begin security scan code ###

    RE_IMAGE_PATTERN = re.compile(r'gcr.io/stackdriver-microservices-demo/.*')

    for container in req["parent"]["spec"]["template"]["spec"]["containers"]:
        if re.match(RE_IMAGE_PATTERN, container["image"]):
            desired_status["passed"].append("%s: %s" % (container["name"], container["image"]))

            deploy = copy.deepcopy(req["parent"])
            deploy.update({"apiVersion": "apps/v1", "kind": "Deployment"})
            deploy["metadata"].update({"resourceVersion": None})
            desired_deploys["Deployment.apps/v1"] = deploy
        else:
            desired_status["failed"].append("%s: %s" % (container["name"], container["image"]))

    ### End security scan code ###

    return jsonify({'status': desired_status, 'children': desired_deploys.values()})

if __name__ == '__main__':
    port = int(os.environ.get("APP_PORT","80"))
    app.run(host='0.0.0.0', port=port, debug=True)
