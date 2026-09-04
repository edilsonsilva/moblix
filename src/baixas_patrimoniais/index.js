const route = require("express").Router();
const conexao = require("../database/config.js")



route.post("/insert",(req,res)=>{
    conexao.query(`INSERT INTO baixas_patrimoniais SET ?`,req.body,(error,result)=>{
        if(error){
        return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
    }
    return res.status(201).send({flag:`OK`,payload:result})
    })
});

route.get("/list",(req,res)  =>{
    conexao.query(`SELECT * FROM baixas_patrimoniais`,(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_id/:id",(req,res)=>{
    conexao.query(`SELECT * FROM baixas_patrimoniais WHERE id=?`,req.params.id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_patrimonio_id/:patrimonio_id",(req,res)=>{
    conexao.query(`SELECT * FROM baixas_patrimoniais WHERE patrimonio_id=?`,req.params.patrimonio_id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_tipo_baixa/:tipo_baixa",(req,res)=>{
    conexao.query(`SELECT * FROM baixas_patrimoniais WHERE tipo_baixa=?`,req.params.patrimonio_id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})


route.get("/list_motivo/:motivo",(req,res)=>{
    const q = `%${req.params.motivo}%`
    conexao.query(`SELECT * FROM baixas_patrimoniais WHERE motivo LIKE ?`,q,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})


route.put("/update/:id",(req,res)=>{
    conexao.query(`UPDATE baixas_patrimoniais SET ? WHERE id = ?`,[req.body, req.params.id],(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao tentar atualizar os dados da patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,playload:result})
    })
})

module.exports = route;