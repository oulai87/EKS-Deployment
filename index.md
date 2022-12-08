---
layout: default
# even an empty front matter is ok
---

<p align="center">
  <img src="https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/K8s-Quckstart.jpg" />
</p>

So it’s 2021 & everybody wants to move their applications to Kubernetes. As a matter of fact, this is still unknown territory to a lot of developers. Having to go through endless tutorials & blogs just for getting started can be daunting, especially when you have deadlines to meet. We know there's Minikube & similar other tools out there, but enterprise cloud environments & their constraints are often hard to replicate locally.

Not anymore, though!

Here is a solution that helps you start deploying and testing your application on Amazon’s Elastic Kubernetes Service with practically zero knowledge of the underlying architecture. It uses a combination of Terraform scripts, Helm Charts and GitHub Actions to deploy all of the resources seamlessly. All you need is an AWS Account, an IAM Admin User, & your source code with its Dockerfile. That’s it!  With just a few clicks, you'll be good to deploy a fully-managed Kubernetes cluster with a live runnning application accessible via a public/private URL. No CLIs, no utilities and no dependencies!

Let’s get started.
<br />
## **What We Are Building**
With this solution, we intend to setup an EKS cluster with a managed node-group, ingress resources, RBAC & Security components and application workloads for 2 sample apps - one React and another Angular. To keep costs low, we deploy only 2 worker nodes by default. The container images will be stored in Amazon's Elastic Container Registry (ECR). The infrastructure components\* will be created and managed by Terraform, with the state file stored and updated within the repository itself.

All of these deployments are orchestrated using Github Actions - Github's in-house CI-CD solution - through a series of cascaded workflows representing different stages in the deployment pipeline. Once your development is completed and you no longer need the resources, you have the option of destroying them with - you guessed it right - a single click, using a separate workflow which ensures that all your deployed resources are cleaned up.

Users have 2 options of deploying the cluster:

1. **Use an existing VPC and subnets** - If you have an existing cloud environment with pre-configured VPC, subnets, networking components and route tables, you can make use of those and let the solution handle only the cluster part for you. In case you use private subnets, make sure you have a NAT gateway so that your nodes are able to communicate with the Kube API server.

2. **Use a new VPC** - If you want to create a new VPC in your account, you can do that as well. In this case, ensure that you don't have an existing VPC within the CIDR range **10.0.0.0/16**. Your networking components will be managed by the terraform workspace in the repository and will be deleted along with the cluster in case you hit that destroy button.

The control plane will have both public and private endpoint access so that GitHub Actions can communicate with it.

**\*Please note that implementing this solution will incur costs for provisioning and using AWS resources, even if you use a free-tier enabled account, so proceed at your own discretion. Go through the comprehensive list of provisioned resources below and use [AWS price calculator](https://calculator.aws/#/) to determine how much you may have to pay based on your usage:**

| AWS Resource               | # of Instances |
|----------------------------|----------------|
| EKS Cluster                | 1              |
| t2.small worker nodes      | 2              |
| NAT Gateway (For new VPCs) | 1              |
| ECR Repository             | 2              |
| Elastic IP (For new VPCs   | 1              |
| Network Load Balancer      | 1              |

<br />

## **Setting Things Up**

### **1. Cloning the repository:**

For starters, clone [this](https://github.com/Mkejriwal270/K8s-EKS-QuickStart) repository in your GitHub account. It has been created as a [template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template), so clicking on **Use this template** on the homepage will create a new repository in your account with the existing file structure intact.

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/repo-page.png)
<br />


### **2. AWS Setup:**

If you don't already have an AWS account, you can create one by following [these](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account) steps.

Make sure you have an IAM User with admin access which can provision resources on your behalf through GitHub Actions. Follow [this](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html) page for more details.

Once your IAM user is configured, you will have to generate a programmatic access key for the user with which GitHub Actions can access your AWS account. Follow the instructions [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) and save the credentials for the next steps.

Optionally, if you want to use a pre-configured VPC, you can take a note of your **VPC ID, Subnet IDs (public and private, if any) and the region where these resources are set up.** You will still need an IAM user and the access key for provisioning the cluster and deploying the application.

Your AWS account is now all set to host your EKS cluster!
<br />
### **3. GitHub Actions Configuration:**

Now you need to configure your repository so that GitHub Actions can deploy resources in your account. Here you will need:

- Your Access Key ID and Secret Access Key generated in the previous step
- Your AWS Account ID - [How to know yours](https://docs.aws.amazon.com/general/latest/gr/acct-identifiers.html)
- A Personal Access Token for your GitHub Account with full access to your repo and workflows - [Generate yours](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

Once you have all these details handy, go to your repository **Settings** > **Secrets** and add a new secret **AWS_ACCESS_KEY_ID** as shown below. Copy the AWS Access Key ID you created and paste in the secret value, without any spaces or line breaks.

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Create-Secret.png)
<br />

Similarly create all the secrets as shown below:

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Secret-List.png)
<br />

The secret names above refer to the following values:

- **AWS_ACCESS_KEY_ID** : Your AWS access key ID
- **AWS_SECRET_ACCESS_KEY** : Your AWS secret access key
- **K8S_QS_TOKEN** : Your Personal Access Token created earlier
- **AWS_ACCOUNT** : Your AWS account ID

These secret names are being referred in the GitHub Actions workflows, so it is recommended to store them exactly as shown here to avoid runtime issues.

For more details go through the [project documentation](https://github.com/Mkejriwal270/K8s-EKS-QuickStart/blob/main/README.md).
<br />
## **Running the Solution**

Enough with all the setup. It's now time to see things in action, literally!

On your repository homepage, go to **Actions** tab, and click on **Fire-it-Up** ( I had to make it dramatic! )

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/workflow-view.png)
<br />
This is basically a "parent" GitHub Actions workflow which invokes a series of different "child" workflows based on parameters entered by the user as inputs. These worflows perform the following tasks in the given order:

- Provision EKS cluster, ECR repository and other AWS resources using Terraform
- Provision Kubernetes RBAC and Ingress resources using Helm
- Build sample apps using Dockerfiles
- Deploy sample app images as Kubernetes workloads and expose them via Ingress Controllers using Helm
<br />
<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/workflow-list.png)
<br />

On the top-right corner, click on **Run workflow** and enter the values in the dropdown form as follows:

1. **Are you using an existing VPC? (true/flase)**: Here you need to specify **true** if you want to use your own VPC, or **false** if you want to create a new one.

2. **Enter cluster name**: The name you want to give to your cluster

3. **Enter space separated existing subnet ids**: If you opted **true** for the first parameter, you need to enter the IDs of the subnets where you want to deploy your worker nodes. For example - **subnet-xytyc1872j subnet-034792hdjd**. This value as well the next one can be left blank in case of new VPCs.

4. **Enter existing vpc id**: If you opted **true** for the first parameter, you need to specify your VPC id.

5. **Enter app version for React**: You can specify any version number of your choice and it will be tagged to your container image and updated in the chart app version. For example - **0.0.1**

6. **Enter app version for Angular**: Same as above

7. **Enter AWS Region**: Enter the AWS region wherein you want to deploy your cluster. For existing VPCs, this should be where your VPC is hosted. For example - **us-east-1**


Once your inputs are ready, click on the **Run workflow** button. 

That's all! 

Your new K8s cluster and application will be deployed shortly. Usually, EKS takes around 10-15 minutes to provision a new cluster, giving you enough time to grab a coffee or a snack after all the hard work you've done!

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Workflow-overview-initial.png)
<br />
If you look at the Actions tab, a new instance of the **Fire-it-Up** workflow has been triggered. Clicking on it will show you a visual summary of the solution and a detailed execution log of each stage in real-time. If any of these stages fail, the execution stops completely.

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Workflow-terraform.png)
<br />

## **Accessing the apps**

Once the workflow execution is completed, you will be able to access your apps using an AWS Network Load Balancer (NLB) URL, deployed by NGINX ingress-controller service.
<br />
<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Workflow-overview.png)
<br />

Go to the succesfully completed execution of the **Fire-it-Up** workflow and click on **setup_infra_components / Helm_Install**. This is the stage where all ingress resources are provisioned. In the execution logs, click on the **Get LB URL** step and copy the **EXTERNAL IP** from the command drop-down. This is the public URL of your application.

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Workflow-exec.png)
<br />

The routes for the application are configured in the application ingress. The sample apps are available at the **/angular-app** and **/react-app** locations as shown below. These can be customized according to your application requirements.

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Angular-App.png)
<br />

<br />

<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/React-App.png)
<br />

## **Cleaning-up resources**

As discussed earlier, you have the option of destroying all resources once you are done with your development. This is a handy feature for developers who use their personal accounts for trying stuff out and need to keep a check on their AWS bills. Go to the Actions tab in your repo home-page and click on **Destroy-All**.

![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Destroy-init.png)

<br />
Similar to the resource creation workflow, the exact values need to be entered accordingly so that Terraform can perform a clean-up of your resources. 
<br />
<br />
This is also a multi-stage pipeline like the previous one, which first deletes the ingress resources including the load-balancer using helm charts and then the rest of the resources.
<br />
<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Destroy-Overview.png)
<br />
<br />
![Image](https://mktestweb.s3.amazonaws.com/K8s-Quickstart-Static/Destroy-Log.png)


## **Customization**

Since the central idea of this solution is simplicity and flexibility, there are countless areas where it can be fine-tuned to meet requirements specific to your use case. For example:
- Inside the [app]() folder, the sample application source code folders can be easily replaced with your own app folder. This would require all references of the folder like [angular]() or [react]() to be replaced with your own app name.
- The API server endpoint can be restricted to a private network by modifying the eks.tf file in the [existing]() or [new]() vpc folder.
- The application itself can be made private by specifying the load-balancer type as internal in the ingress-controler service manifest [file]().
- The worker node type can be changed based on different kinds of workloads in the eks.tf file

The possibilities are endless and we will discuss some of these use-cases in a separate post related to this project. The extended documentation for the project will be updated soon.

## **Further Reading**

Although this project has been designed to ensure minimum dependency on documentation or tutorials, the following links can be useful to understand how these technologies work under the hood and how they can be tweaked to meet our requirements:

Kubernetes - [Official docs](https://kubernetes.io/docs/home/)<br />
Ingress - [Official docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)<br />
GitHub Actions - [GitHub docs](https://docs.github.com/en/actions)<br />
Terraform - [Hashicorp docs](https://www.terraform.io/docs/index.html)<br />
Helm - [Official docs](https://helm.sh/docs/)<br />
AWS - [Official docs](https://aws.amazon.com/eks/)<br />

## **About Me**

I am Milind, a Cloud & DevOps engineer from Bangalore, India. I love talking about all things cloud, physics and tech in general. If you face any issues related to the project, or if you just want to chat about any tech ideas, shoot me an email at milindkejriwal270@gmail.com or reach out to me via any of the following channels. 

<!-- Please don't remove this: Grab your social icons from https://github.com/carlsednaoui/gitsocial -->

<!-- display the social media buttons in your README -->

[![alt text][1.1]][1]
<a href="https://www.linkedin.com/in/milind-kejriwal"><img src="https://icon-library.com/images/linkedin-icon-black-and-white/linkedin-icon-black-and-white-25.jpg" width="23" height="23" style="padding-bottom: 4px;"/></a>
[![alt text][3.1]][3]


<!-- links to social media icons -->
<!-- no need to change these -->

<!-- icons with padding -->

[1.1]: http://i.imgur.com/tXSoThF.png (twitter icon with padding)
[2.1]: https://icon-library.com/images/linkedin-icon-black-and-white/linkedin-icon-black-and-white-25.jpg (linkedin icon with padding)
[3.1]: http://i.imgur.com/0o48UoR.png (github icon with padding)


<!-- links to your social media accounts -->
<!-- update these accordingly -->

[1]: https://www.twitter.com/KejriwalMilind
[2]: https://www.linkedin.com/in/milind-kejriwal
[3]: https://www.github.com/Mkejriwal270

<!-- Please don't remove this: Grab your social icons from https://github.com/carlsednaoui/gitsocial -->



